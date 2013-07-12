module GoogleSafeBrowsing
  # Helper methods for working with binary encoded data from Forwarding URLs
  class BinaryHelper

    # Reads `counter` byes from byte iterator `iter` and returns the hex string represnetation
    #
    # @param [ByteIterator] iter byte iterator already at correct position
    # @param [Integer] count number of bytes to read
    # @return [String] hexidecimal string
    def self.read_bytes_as_hex(iter, count)
      read_bytes_from(iter, count).unpack("H#{count * 2}")[0]
    end

    # Returns the first four bytes of `string` as hexidecimal
    #
    # @param [String] string to unpack the first four bytes as hex
    # @return (see read_bytes_as_hex)
    def self.four_as_hex(string)
      string.unpack('H8')[0]
    end


    # Read `count` bytes from `iter` without unpacking the result
    #
    # @param (see read_bytes_as_hex)
    # @return (String) not unpacked string from `iter`
    def self.read_bytes_from(iter, count)
      iter = iter.to_enum if iter.is_a?(Array)

      ret = ''
      count.to_i.times { ret << iter.next }
      ret
   #rescue
   #  puts "Tried to read past chunk iterator++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   #  return nil
    end

    # Returns the first four bytes of `string` as hexidecimal; for host key
    # @param (String) bin string to unpack
    # @return (String) unpacked string
    def self.unpack_host_key(bin)
      bin.unpack('H8')[0]
    end

    # Unpack string as an unsigned integer; for count
    #
    # @param (see unpack_host_key)
    # @return (see unpack_host_key)
    def self.unpack_count(bin)
      # this may not be correct
      bin.unpack('U')[0]
    end

    # Unpack string as big-endian network byte order
    #
    # @param (see unpack_count)
    # @return (see unpack_count)
    def self.unpack_add_chunk_num(bin)
      bin.unpack('N')[0]
    end

    # Pack a Hex String into binary
    #
    # @param (String) hex string to encode
    # @return (String) encoded string
    def self.hex_to_bin(hex)
      [hex].pack('H*')
    end

  end
end
