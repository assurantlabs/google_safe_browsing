module GoogleSafeBrowsing
  class ChunkList
    def initialize(raw_chunks)
      @raw_chunk_list = raw_chunks
    end

    def to_a
      list = []
      @raw_chunk_list.split(',').each do |item|
        if item.index('-')
          range = item.split('-')
          list += Array(range[0]..range[1])
        else
          list << item
        end
      end
      list
    end
  end
end
