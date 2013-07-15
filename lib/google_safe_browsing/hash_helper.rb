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

    def self.urls_to_hashes(urls)
      hashes = []
      urls.each do |u|
        hash = ( Digest::SHA256.new << u ).to_s
        hashes << GsbHash.new(hash)
      end
      hashes
    end

    def self.raw_to_gsb_hashes(raw_hashes)
      raw_hashes.map { |raw_hash| GsbHash.new(raw_hash) }
    end
  end
end
