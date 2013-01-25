module GoogleSafeBrowsing
  class KeyHelper

    def self.web_safe_base64_decode(str)
      str.tr!('-_', '+/')
      str << '=' while str.length % 4 != 0
      Base64.decode64(str)
    end

    def self.compute_mac_code(data)
      sha1 = OpenSSL::HMAC.digest('sha1', GoogleSafeBrowsing.config.client_key, data)
      Base64.encode64(sha1).chomp
    end
  end
end

