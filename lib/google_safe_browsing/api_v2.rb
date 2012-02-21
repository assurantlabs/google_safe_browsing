module GoogleSafeBrowsing
  class APIv2
    def self.update
      data_response = get_data

      to_do_array = parse_data_response(data_response.body)

      #delay(to_do_array[:delay_seconds])

      to_do_array[:lists].each do |list|
        to_do_array[:data_urls][list].each do |url|
          receive_data('http://' + url, list)
        end
      end
    end

    def self.get_data(list=nil)
      # Get (via Post) List Data
      uri = uri_builder('downloads')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = build_chunk_list(list)

      Net::HTTP.start(uri.host) { |http| http.request request }
    end

    def self.parse_data_response(response)
      data_urls = []
      ret = {}

      ret[:lists] = []
      ret[:data_urls] = Hash.new([])
      # each data_urls is a with an array as a value:
      # ret[:data_urls] = {
      #                     'list-name-here' => [
      #                       'redirect.url.com/blah1',
      #                       'redirect.url.com/blah2',
      #                       'redirect.url.com/blah3',
      #                     ],
      #                     'list-name-here-too' => [
      #                       'redirect.google.com/blah1',
      #                       'redirect.google.com/blah2',
      #                       'redirect.google.com/blah3',
      #                     ]
      #                   }

      response.split("\n").each do |line|
        vals = line.split(':')
        case vals[0]
        when 'n'
          ret[:delay_seconds] = vals[1].to_i
        when 'i'
          ret[:lists] << vals[1]
        when 'u'
          ret[:data_urls][ret[:lists].last] << vals[1]
        when 'r'
          # reset (delete all data and try again)
        when 'ad'
          # vals[1] is a CHUNKLIST number or range representing add chunks to delete
          # we no longer have to report hat we received these chunks
        when 'sd'
          # vals[1] is a CHUNKLIST number or range representing sub chunks to delete
          # we no longer have to report hat we received these chunks
        end
      end

      #ret[:data_urls] = data_urls

      ret
    end

    def self.receive_data(url, list)
      open(url) do |f|
        while(line = f.gets)
          line_actions = parse_data_line(line)

          chunk  = f.read(line_actions[:chunk_length])
          # f iterator is now set for next chunk

          record_chunk(line_actions[:action], line_actions[:chunk_number], list)

          if line_actions[:chunk_length] == 0
            puts "No Chunk Data Here, move along"
            next
          end

          chunk_iterator = chunk.bytes
          host_key = four_as_hex( read_bytes_from(chunk_iterator, 4) )
          count = chunk_iterator.next

          case line_actions[:action]
          when 'a'
            add_chunk(chunk_iterator, count, line_actions[:hash_length], host_key, line_actions[:chunk_number], list)
          when 's'
            sub_chunk(chunk_iterator, count, line_actions[:hash_length], host_key, list)
          else
            puts "neither a nor s ======================================================="
          end
        end
      end
    end
    
    def self.record_chunk(action, chunk_nummber, list)
      Chunk.new!(:chunk_type => action, :chunk_number => chunk_number, :list => list)
    end

    def self.delay(delay_seconds)
      puts "Google told us to wait for #{delay_seconds} seconds"
      puts "We will wait...."
      start_time = Time.now
      while(start_time + delay_seconds > Time.now)
          puts "#{(delay_seconds - (Time.now - start_time)).to_i}..."
          sleep(10)
      end
      puts "Thank you for being patient"
    end



    def self.parse_data_line(line)
      split_line = line.split(':')

      ret = {}
      ret[ :action ]        = split_line[0]
      ret[ :chunk_number ]  = split_line[1].to_i
      ret[ :hash_length ]   = split_line[2].to_i
      ret[ :chunk_length ]  = split_line[3].to_i

      #puts "Chunk ##{s_chunk_count + a_chunk_count}"
      #puts "Action: #{action}"
      #puts "Chunk Number: #{split_line[1]}"
      #puts "Hash Length: #{hash_length}"
      #puts "Chunk Length: #{chunk_length}"
      ##puts "Chuch Data:\n#{chunk}\nend"
      ret
    end


    def self.add_chunk(chunk_iterator, count, hash_length, host_key, chunk_number, list)
      if count == 0
        ShavarHash.new!(:prefix => host_key, :host_key => host_key, 
                        :chunk_number => chunk_number, :list => list)
      else
        count.times do |i|
          prefix = read_bytes_from(chunk_iterator, hash_length)
          ShavarHash.new!(:prefix => prefix, :host_key => host_key, 
                          :chunk_number => chunk_number, :list => list)
          puts "  with this prefix: #{four_as_hex( prefix )}"
        end
      end
    end

    def self.sub_chunk(chunk_iterator, count, hash_length, host_key, list)
      chunk_number = read_bytes_from(chunk_iterator, 4)
      if count == 0
        puts "Sub this chunk number: #{four_as_network_order_int( chunk_num )}"
        hash = ShavarHash.where(:prefix => host_key, :host_key => host_key, 
                                :chunk_number => chunk_number, :list => list).first
        hash.destroy if hash
      else
        count.times do |i|
          puts " #{i } chunk number to remove: #{four_as_network_order_int( chunk_num )}"
          prefix = read_bytes_from(chunk_iterator, hash_length)
          puts "  with this prefix: #{four_as_hex( prefix )}"
          hash = ShavarHash.where(:prefix => prefix, :host_key => host_key, 
                                  :chunk_number => chunk_number, :list => list).first
          hash.destroy if hash
        end
      end
    end

    def get_lists
      uri = uri_builder('list')
      lists = Net::HTTP.get(uri).split("\n")
    end


    def self.build_chunk_list(list=nil)
      # this should eventually query the database for chunk numbers and build a chunk list
      # Do this after implementing persistence
      lists = if list
                list.to_a
              else
                CURRENT_LISTS
              end

      ret = ''
      lists.each do |list|
        ret += "#{list};\n"
      end

      ret
    end

    def self.uri_builder(action)
      URI("#{HOST}/#{action}#{encode_www_form(PARAMS)}")
    end

    def self.encode_www_form(hash)
      param_strings = []
      hash.each_pair do |key, val|
        param_strings << "#{ key }=#{ val }"
      end
      "?#{param_strings.join('&')}"
    end

    def self.four_as_hex(string)
      string.unpack('h8')[0]
    end
    def self.four_as_network_order_int(string)
      string.unpack('N')[0]
    end

    def self.read_bytes_from(iter, count)
      ret = ''
      count.to_i.times { ret << iter.next }
      ret
    rescue
      puts "Tried to read past chunk iterator++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      return ret
    end

  end
end
