module GoogleSafeBrowsing
  class HttpHelper
    def self.uri_builder(action, use_ssl=false)
      host = GoogleSafeBrowsing.config.host
      host = switch_to_https(host) if use_ssl

      uri = URI("#{host}/#{action}#{encoded_params}")
      uri
    end

    def self.request_full_hashes(hash_array)
      uri = uri_builder('gethash')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = "4:#{hash_array.length * 4}\n"
      hash_array.each do |h|
        request.body << BinaryHelper.hex_to_bin(h[0..7])
      end

      response = Net::HTTP.start(uri.host) { |http| http.request request }

      if response.is_a?(Net::HTTPSuccess) && !response.body.blank?
        ResponseHelper.parse_full_hash_response(response.body)
      else
        []
      end
    end

    def self.get_data(list=nil)
      uri = uri_builder('downloads')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = ChunkHelper.build_chunk_list(list)

      Net::HTTP.start(uri.host) { |http| http.request request }
    end

    def get_lists
      uri = uri_builder('list')
      Net::HTTP.get(uri).split("\n")
    end


    private
      def self.encoded_params
        params = "?client=#{GoogleSafeBrowsing.config.client}" <<
        "&apikey=#{GoogleSafeBrowsing.config.api_key}" <<
        "&appver=#{GoogleSafeBrowsing.config.app_ver}" <<
        "&pver=#{GoogleSafeBrowsing.config.p_ver}"

        params << "&wrkey=#{GoogleSafeBrowsing.config.wrapped_key}" if GoogleSafeBrowsing.config.have_keys?

        params
      end

      def self.switch_to_https(url)
        "https#{url[4..-1]}"
      end
  end
end
