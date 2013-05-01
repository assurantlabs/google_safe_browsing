module GoogleSafeBrowsing
  class HttpHelper
    def self.uri_builder(action, use_ssl=false)
      host = GoogleSafeBrowsing.config.host
      host = switch_to_https(host) if use_ssl

      uri = URI("#{host}/#{action}#{encoded_params}")
      uri
    end

    def self.request_full_hashes(hash_array)
      get_keys unless GoogleSafeBrowsing.config.have_keys?

      uri = uri_builder('gethash')

      response = post_data(uri) do
        body = "4:#{hash_array.length * 4}\n"
        hash_array.each do |h|
          body << BinaryHelper.hex_to_bin(h[0..7])
        end

        body
      end

      if response.is_a?(Net::HTTPSuccess) && !response.body.blank?
        ResponseHelper.parse_full_hash_response(response.body)
      else
        []
      end
    end

    def self.get_data(list=nil)
      uri = uri_builder('downloads')

      post_data(uri) do
        ChunkHelper.build_chunk_list(list)
      end
    end

    def self.get_keys
      uri = URI("#{GoogleSafeBrowsing.config.rekey_host}/newkey#{encoded_params}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body.split("\n").each do |key_line|
        key_name, _, key_value = key_line.split(':')
        key_value.gsub!('=', '')

        case key_name
        when 'clientkey'
          key_value = KeyHelper::web_safe_base64_decode(key_value)
          GoogleSafeBrowsing.config.client_key = key_value
        when 'wrappedkey'
          GoogleSafeBrowsing.config.wrapped_key = key_value
        end
      end
    end

    private
      REKEY_PREFIX = 'e:pleaserekey'

      def self.encoded_params
        params = "?client=#{GoogleSafeBrowsing.config.client}" <<
        "&apikey=#{GoogleSafeBrowsing.config.api_key}" <<
        "&appver=#{GoogleSafeBrowsing.config.app_ver}" <<
        "&pver=#{GoogleSafeBrowsing.config.p_ver}"

        params << "&wrkey=#{GoogleSafeBrowsing.config.wrapped_key}" if GoogleSafeBrowsing.config.have_keys?

        params
      end

      def self.with_keys(uri)
        begin
          get_keys unless GoogleSafeBrowsing.config.have_keys?
          response = yield uri
        end while self.please_rekey?(response.body)

        lines = response.body.split("\n")
        mac = lines.shift
        if mac[0..1] == 'm:'
          mac = mac[2..-1].chomp
          data = lines.join("\n") << "\n"
        else
          data = lines.join("\n")
        end

        if self.valid_mac?(data, mac)
          response
        else
          raise InvalidMACValidation, "The MAC returned from '#{uri}' is not valid."
        end
      end

      def self.valid_mac?(data, mac)
        KeyHelper.compute_mac_code(data) == mac
      end

      def self.post_data(uri)
        with_keys uri do
          request = Net::HTTP::Post.new(uri.request_uri)
          request.body = yield uri

          Net::HTTP.start(uri.host) { |http| http.request request }
        end
      end

      def self.please_rekey?(body)
        if body.split("\n").include? REKEY_PREFIX
          GoogleSafeBrowsing.config.client_key = nil
          GoogleSafeBrowsing.config.wrapped_key = nil
          true
        else
          false
        end
      end

      def self.switch_to_https(url)
        "https#{url[4..-1]}"
      end
  end
end
