module GoogleSafeBrowsing
  class BinaryHelper

    def self.read_bytes_as_hex(iter, count)
      read_bytes_from(iter, count).unpack("H#{count * 2}")[0]
    end

    def self.four_as_hex(string)
      string.unpack('H8')[0]
    end


    def self.read_bytes_from(iter, count)
      ret = ''
      count.to_i.times { ret << iter.next }
      ret
    rescue
      puts "Tried to read past chunk iterator++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      return ret
    end

    def unpack_host_key(bin)
      bin.unpack('H8')[0]
    end

    def self.unpack_count(bin)
      # this may not be correct
      bin.unpack('U')[0]
    end

    def self.unpack_add_chunk_num(bin)
      bin.unpack('N')[0]
    end

  end
end
