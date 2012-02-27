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
        #puts "#{u} -- #{hash}"
      end
      hashes
    end
  end
end
