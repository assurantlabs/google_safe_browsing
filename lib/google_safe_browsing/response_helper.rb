module GoogleSafeBrowsing
  class ResponseHelper
    def self.parse_full_hash_response(response)
      f = StringIO.new(response)

      full_hashes = []
      while(! f.eof? )
        hash = {}

        meta = f.gets.chomp.split(':')
        hash[:list] = meta[0]
        hash[:add_chunk_num] = meta[1]

        hash[:full_hash] = f.read(meta[2].to_i).unpack('H*')[0]
        full_hashes << hash
      end
      full_hashes
    end

    def self.parse_data_response(response)
      ret = {}

      ret[:lists] = []
      ret[:data_urls] = {}

      current_list = ''
      response.split("\n").each do |line|
        vals = line.split(':')
        case vals[0]
        when 'n'
          ret[:delay_seconds] = vals[1].to_i
          @delay_seconds = ret[:delay_seconds].to_i
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
          # we no longer have to report that we received these chunks
          chunk_number_clause = ChunkHelper.chunklist_to_sql(vals[1])
          AddShavar.delete_all([ "list = ? and (?)", current_list, chunk_number_clause ])
        when 'sd'
          # vals[1] is a CHUNKLIST number or range representing sub chunks to delete
          # we no longer have to report that we received these chunks
          chunk_number_clause = ChunkHelper.chunklist_to_sql(vals[1])
          SubShavar.delete_all([ "list = ? and (?)", current_list, chunk_number_clause ])
        end
      end

      ret
    end

    def self.receive_data(url, list)
      urls = url.split(',')
      url = urls[0]
      mac = urls[1]

      open(url) do |f|
        body = f.read

        unless mac.blank? || HttpHelper.valid_mac?(body, mac)
          raise InvalidMACVerification
        end

        f.rewind

        while(line = f.gets)
          line_actions = parse_data_line(line)

          chunk  = f.read(line_actions[:chunk_length])
          # f iterator is now set for next chunk

          add_attrs = { :chunk_number => line_actions[:chunk_number],
                    :list => list, :prefix => nil, :host_key => nil
                  }

          case line_actions[:action]
          when 'a'
            if line_actions[:chunk_length] == 0
              record_add_shavar_to_insert(add_attrs)
            else
              chunk_iterator = chunk.bytes.to_enum
              counter = 0
              begin
                while true
                  add_attrs[:host_key] = BinaryHelper.read_bytes_as_hex(chunk_iterator, 4)
                  count = chunk_iterator.next
                  if count > 0
                    count.times do |i|
                      add_attrs[:prefix] = BinaryHelper.read_bytes_as_hex(chunk_iterator, line_actions[:hash_length])
                      record_add_shavar_to_insert(add_attrs)
                    end
                  else
                    add_attrs[:prefix] = add_attrs[:host_key]
                    record_add_shavar_to_insert(add_attrs)
                  end
                  counter += 1
                end
              rescue StopIteration
                puts "Added #{counter} host_keys for add chunk number #{line_actions[:chunk_number]}"
              end
            end
          when 's'
            sub_attrs = add_attrs.merge({ :add_chunk_number => nil })
            if line_actions[:chunk_length] == 0
              record_sub_shavar_to_insert(sub_attrs)
            else
              chunk_iterator = chunk.bytes.to_enum
              counter = 0
              begin
                while true
                  sub_attrs[:host_key] = BinaryHelper.read_bytes_as_hex(chunk_iterator, 4)
                  count = chunk_iterator.next
                  if count > 0
                    count.times do |i|
                      sub_attrs[:add_chunk_number] = BinaryHelper.unpack_add_chunk_num(BinaryHelper.read_bytes_from(chunk_iterator, 4))
                      sub_attrs[:prefix] = BinaryHelper.read_bytes_as_hex(chunk_iterator, line_actions[:hash_length])
                      record_sub_shavar_to_insert(sub_attrs)
                    end
                  else
                    sub_attrs[:add_chunk_number] = BinaryHelper.unpack_add_chunk_num(BinaryHelper.read_bytes_from(chunk_iterator, 4))
                    sub_attrs[:prefix] = sub_attrs[:host_key]
                    record_sub_shavar_to_insert(sub_attrs)
                  end
                  counter += 1
                end
              rescue StopIteration
                puts "Added #{counter} host_keys for sub chunk number #{line_actions[:chunk_number]}"
              end
            end
          else
            puts "neither a nor s ======================================================="
          end

        end
      end

      while @add_shavar_values && @add_shavar_values.any?
        AddShavar.connection.execute <<-SQL
          INSERT INTO gsb_add_shavars (prefix, host_key, chunk_number, list)
          VALUES #{pop_and_join @add_shavar_values}
          SQL
      end
      while @sub_shavar_values && @sub_shavar_values.any?
      SubShavar.connection.execute <<-SQL
        INSERT INTO gsb_sub_shavars (prefix,
                                     host_key,
                                     add_chunk_number,
                                     chunk_number,
                                     list)
        VALUES #{pop_and_join @sub_shavar_values}
        SQL
      end

      FullHash.connection.execute <<-SQL
        DELETE FROM gsb_full_hashes
        USING gsb_full_hashes
        INNER JOIN  gsb_sub_shavars ON
        gsb_sub_shavars.add_chunk_number = gsb_full_hashes.add_chunk_number
        AND gsb_sub_shavars.list = gsb_full_hashes.list;
        SQL

      @add_shavar_values = []
      @sub_shavar_values = []
    end

    def self.record_add_shavar_to_insert(h)
      @add_shavar_values ||= []
      values = [ h[:prefix], h[:host_key], h[:chunk_number], h[:list] ]
      @add_shavar_values << "(#{escape_and_join values})"
    end
    def self.record_sub_shavar_to_insert(h)
      @sub_shavar_values ||= []
      values = [ h[:prefix],
                 h[:host_key],
                 h[:add_chunk_number],
                 h[:chunk_number],
                 h[:list] ]
      @sub_shavar_values << "(#{escape_and_join values})"
    end

    def self.parse_data_line(line)
      split_line = line.split(':')

      ret = {}
      ret[ :action ]        = split_line[0]
      ret[ :chunk_number ]  = split_line[1].to_i
      ret[ :hash_length ]   = split_line[2].to_i
      ret[ :chunk_length ]  = split_line[3].to_i
      ret
    end

    def self.escape_and_join(values)
      values.map do |v|
        ActiveRecord::Base::sanitize(v)
      end.join(', ')
    end

    def self.pop_and_join(records)
      records.pop(10000).join(', ')
    end
  end
end
