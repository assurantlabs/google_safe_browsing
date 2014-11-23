module GoogleSafeBrowsing
  class HttpHelper
    def self.uri_builder(action, use_ssl=false)
      host = GoogleSafeBrowsing.config.host

      uri = URI("#{host}/#{action}#{encoded_params}")
      uri
    end

    def self.request_full_hashes(hash_array)
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

    private

    def self.encoded_params
      "?client=#{GoogleSafeBrowsing.config.client}" <<
      "&apikey=#{GoogleSafeBrowsing.config.api_key}" <<
      "&appver=#{GoogleSafeBrowsing.config.app_ver}" <<
      "&pver=#{GoogleSafeBrowsing.config.p_ver}"
    end

    def self.post_data(uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = yield uri

      Net::HTTP.start(uri.host) { |http| http.request request }
    end
  end
end
