module GoogleSafeBrowsing
  class HashHelper

    class GsbHash
      def initialize(hash)
        @hash = hash
      end

      def prefix
        @hash[0..7]
      end

      def to_s
        @hash
      end

    end

    def self.urls_to_gsb_hashes(urls)
      urls.map do |url|
        raw_hash = Digest::SHA256.new << url
        GsbHash.new(raw_hash.to_s)
      end
    end

    def self.raw_to_gsb_hashes(raw_hashes)
      raw_hashes.map { |raw_hash| GsbHash.new(raw_hash) }
    end
  end
end
