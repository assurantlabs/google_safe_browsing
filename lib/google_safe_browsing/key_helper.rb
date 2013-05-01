module GoogleSafeBrowsing
  class KeyHelper

    def self.web_safe_base64_decode(str)
      str.tr!('-_', '+/')
      str << '=' while str.length % 4 != 0
      Base64.decode64(str)
    end

    def self.web_safe_base64_encode(str)
      str = Base64.encode64(str).chomp
      str.tr('+/', '-_')
    end

    def self.compute_mac_code(data)
      sha1 = OpenSSL::HMAC.digest('sha1',
                                  GoogleSafeBrowsing.config.client_key,
                                  data)
      web_safe_base64_encode sha1
    end
  end
end

