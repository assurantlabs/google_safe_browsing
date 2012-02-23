module GoogleSafeBrowsing
  class APIv2
    def self.update
      data_response = get_data

      to_do_array = parse_data_response(data_response.body)

      #delay(to_do_array[:delay_seconds])

      to_do_array[:lists].each do |list|
        to_do_array[:data_urls][list].each do |url|
          puts "#{list} - #{url}\n"
          receive_data('http://' + url, list)
        end
      end
      @delay_seconds
    end

    def self.lookup(url)
      cann = Canonicalize.url(url)

      urls = Canonicalize.urls_for_lookup(cann)

      hashes = []
      urls.each do |u|
        hash = ( Digest::SHA256.new << u ).to_s
        hashes << hash[0..7]
        puts "#{u} -- #{hash[0..7]}"
      end

      ShavarHash.where(:prefix => hashes).collect{ |s| s.list }
    end

    private

    def self.get_data(list=nil)
      # Get (via Post) List Data
      uri = HttpHelper.uri_builder('downloads')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = build_chunk_list(list)

      Net::HTTP.start(uri.host) { |http| http.request request }
    end

    def self.parse_data_response(response)
      print "\n\n#{response}\n\n"
      data_urls = []
      ret = {}

      ret[:lists] = []
      ret[:data_urls] = {}
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

      current_list = ''
      response.split("\n").each do |line|
        vals = line.split(':')
        case vals[0]
        when 'n'
          ret[:delay_seconds] = vals[1].to_i
          @delay_seconds = ret[:delay_seconds]
        when 'i'
          ret[:lists] << vals[1]
          current_list = vals[1]
          ret[:data_urls][current_list] = []
        when 'u'
          ret[:data_urls][current_list] << vals[1]
        when 'r'
          # reset (delete all data and try again)
        when 'ad'
          # vals[1] is a CHUNKLIST number or range representing add chunks to delete
          # we can also delete the associated Shavar Hashes
          # we no longer have to report hat we received these chunks
          chunk_number_clause = chunklist_to_sql(vals[1], 'chunks.number')
          shavar_number_clause = chunklist_to_sql(vals[1], 'shavar_hashes.chunk_number')
          ShavarHash.delete_all([ "shavar_hashes.list = ? and (#{shavar_number_clause})", ret[:lists].last ])
          Chunk.delete_all([ "chunks.list = ? and chunks.action = ? and (#{chunk_number_clause})", ret[:lists].last, 'a' ])
        when 'sd'
          # vals[1] is a CHUNKLIST number or range representing sub chunks to delete
          # we no longer have to report hat we received these chunks
          chunk_number_clause = chunklist_to_sql(vals[1], 'chunks.number')
          Chunk.delete_all([ "chunks.list = ? and chunks.action = ? and (#{chunk_number_clause})", ret[:lists].last, 's' ])
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
          host_key = BinaryHelper.read_bytes_as_hex(chunk_iterator, 4)
          count = chunk_iterator.next

          if line_actions[:action] == 'a' || line_actions[:action] == 's'
            record_hash(chunk_iterator, count, line_actions[:hash_length], 
                        host_key, line_actions[:chunk_number], list, line_actions[:action])
          else
            puts "neither a nor s ======================================================="
          end
        end
      end
    end

    def self.record_chunk(action, chunk_number, list)
      if chunk = Chunk.where(:number => chunk_number, :list => list).first
        chunk.update_attributes(:action => action)
      else
        Chunk.create(:action => action, :number => chunk_number, :list => list)
      end
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
      ret[ :chunk_number ]  = split_line[1] #.to_i
      ret[ :hash_length ]   = split_line[2] #.to_i
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
        ShavarHash.create(:prefix => host_key, :host_key => host_key,
                        :chunk_number => chunk_number, :list => list, :action => 'a')
      else
        count.times do |i|
          prefix = BinaryHelper.read_bytes_as_hex(chunk_iterator, hash_length)
          ShavarHash.create(:prefix => prefix, :host_key => host_key,
                          :chunk_number => chunk_number, :list => list, :action => 'a')
          #puts "  with this prefix: #{four_as_hex( prefix )}"
        end
      end
    end

    def self.sub_chunk(chunk_iterator, count, hash_length, host_key, list)
      if count == 0
        #puts "Sub this chunk number: #{four_as_network_order_int( chunk_number )}"
        chunk_number = BinaryHelper.unpack_add_chunk_num(BinaryHelper.read_bytes_from(chunk_iterator, 4))
        ShavarHash.create(:prefix => host_key, :host_key => host_key,
                                :chunk_number => chunk_number, :list => list, :action => 's')
      else
        count.times do |i|
          #puts " #{i } chunk number to remove: #{four_as_network_order_int( chunk_number )}"
          chunk_number = BinaryHelper.unpack_add_chunk_num(BinaryHelper.read_bytes_from(chunk_iterator, 4))
          prefix = BinaryHelper.read_bytes_as_hex(chunk_iterator, hash_length)
          #puts "  with this prefix: #{four_as_hex( prefix )}"
          ShavarHash.create(:prefix => prefix, :host_key => host_key,
                                  :chunk_number => chunk_number, :list => list, :action => 's')
        end
      end
    end

    def get_lists
      uri = HttpHelper.uri_builder('list')
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
        ret += "#{list};"
        action_strings = []
        ['a', 's' ].each do |action|
          nums = GoogleSafeBrowsing::Chunk.select(:number).where(:action => action, :list => list).
            order(:number).collect{|c| c.number }
          #puts "#{list}:#{action} - #{nums.size}"
          action_strings << "#{action}:#{squish_number_list(nums)}" if nums.any?
        end
        ret += "#{action_strings.join(':')}\n"
      end

      puts ret
      @chunk_list = ret
      ret
    end

    def self.squish_number_list(chunks)
      num_strings = []

      streak_begin = chunks[0]
      last_num = chunks.shift
      chunks.each do |c|
        if c == last_num+1
          #puts "streak continues"
        else
          #puts "streak has ended"
          if streak_begin != last_num
            streak_string = "#{streak_begin}-#{last_num}"
            #puts "there is a streak: #{streak_string}"
            num_strings << streak_string
          else
            #puts "streak was one long: #{last_num}"
            num_strings << last_num
          end
          streak_begin = c
        end
        last_num = c
      end

      if streak_begin == chunks[-1]
        num_strings << streak_begin
      else
        num_strings << "#{streak_begin}-#{chunks[-1]}"
      end

      num_strings.join(',')
    end

    def self.chunklist_to_sql(chunk_list, column_name)
      ret_array = []
      chunk_list.split(',').each do |s|
        if s.index('-')
          range = s.split('-')
          ret_array << "#{ column_name } between #{range[0]} and #{range[1]}"
        else
          ret_array << "#{ column_name } = #{s}"
        end
      end
      ret_array.join(" or ")
    end

  end
end
