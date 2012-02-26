module GoogleSafeBrowsing
  class HttpHelper
    def self.uri_builder(action)
      uri = URI("#{HOST}/#{action}#{encode_www_form(PARAMS)}")
      puts uri
      uri
    end

    def self.encode_www_form(hash)
      param_strings = []
      hash.each_pair do |key, val|
        param_strings << "#{ key }=#{ val }"
      end
      "?#{param_strings.join('&')}"
    end
  end
end
