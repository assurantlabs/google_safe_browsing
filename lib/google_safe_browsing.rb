require 'net/http'
require 'open-uri'

module GoogleSafeBrowsing

  CLIENT  = 'api'
  API_KEY = 'ABQIAAAAyLR3IaNHXuIIDgTUlo9YORTqV6MDxWSrNbRxMC53QkjhMk0eYw'
  APP_VER = '1'
  P_VER   = '2.2'
  HOST    = 'http://safebrowsing.clients.google.com/safebrowsing'
  PARAMS  = { :client => CLIENT, :apikey => API_KEY, :appver => APP_VER, 
    :pver => P_VER }
  ENCODED_PARAMS = encode_www_form(PARAMS)



  def get_lists
    # Get Lists
    uri = uri_builder('list')
    lists = Net::HTTP.get(uri).split("\n")
  end

  def get_list_data(list)
    # Get (via Post) First List Data
    uri = uri_builder('downloads')
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = "#{ list };\n"

    response = parse_data_response(Net::HTTP.start(uri.host) { |http| http.request request } )

    #delay_for_seconds(response[:delay_seconds])

    @s_chunk_count = 0
    @a_chunk_count = 0
    response[:data_urls].each do |url|
      puts "\n\nOpening #{url}"
      open('http://' + url) do |f|

        while(line = f.gets)
          meta_data = parse_action_line(line)

          if meta_data[:chunk_length] == 0
            puts "No Chunk Here, move along"
            next
          end
          chunk_iterator = meta_data[:chunk].bytes
          host_key = read_bytes_from(chunk_iterator, 4)
          puts "Host Key: #{four_as_hex( host_key )}"
          count = chunk_iterator.next
          puts "Count: #{count}"

          case action
          when 's'
            perform_sub(count, chunk_iterator)

            s_chunk_count += 1
          when 'a'
            if count == 0
              # all urls under host are a match
              # TODO how to implement that
            else
              count.times do |i|
                prefix = read_bytes_from(chunk_iterator, hash_length)
                puts "  with this prefix: #{four_as_hex( prefix )}"
              end
            end

            a_chunk_count += 1
          else
            puts "neither a nor s ======================================================="
          end
          #break
        end
      end
      puts "\n\nso far:\na chunks: #{@a_chunk_count}\ns chunks: #{@s_chunk_count}"
    end
    puts "\n\nFinal:\na chunks: #{@a_chunk_count}\ns chunks: #{@s_chunk_count}"
  end



  private

    def uri_builder(action)
      URI("#{HOST}/#{action}#{ENCODED_PARAMS}")
    end

    def encode_www_form(hash)
      param_strings = []
      hash.each_pair do |key, val|
        param_strings << "#{ key }=#{ val }"
      end
      "?#{param_strings.join('&')}"
    end

    def four_as_hex(string)
      string.unpack('h8')[0]
    end
    def four_as_network_order_int(string)
      string.unpack('N')[0]
    end

    def read_bytes_from(iter, count)
      ret = ''
      count.to_i.times { ret << iter.next }
      ret
    rescue
      puts "Tried to read past chunk iterator++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      return ret
    end

    def parse_data_response(response)
      parsed = {}
      parsed[:data_urls] = []
      response.body.split("\n").each do |line|
        vals = line.split(':')
        case vals[0]
        when 'n'
          parsed[:delay_seconds] = vals[1].to_i
        when 'u'
          parsed[:data_urls] << vals[1]
        when 'r'
          # TODO: delete all client-side data and request again
        end
      end
    end

    def delay_for_seconds(delay_seconds)
      puts "Google told us to wait for #{delay_seconds} seconds"
      puts "We will wait...."
      start_time = Time.now
      while(start_time+ delay_seconds > Time.now)
          puts "#{( delay_seconds - (Time.now - start_time)).to_i}..."
          sleep(10)
      end
      puts "Thank you for being patient"
    end

    def perform_sub(count, chunk_iterator)
      if count == 0
        chunk_num = read_bytes_from(chunk_iterator, 4)
        puts "Remove this chunk number: #{four_as_network_order_int( chunk_num )}"
      else
        count.times do |i|
          add_chunk_num = read_bytes_from(chunk_iterator, 4)
          puts " #{i } chunk number to remove: #{four_as_network_order_int( add_chunk_num )}"
          prefix = read_bytes_from(chunk_iterator, hash_length)
          puts "  with this prefix: #{four_as_hex( prefix )}"
        end
      end
    end

    def parse_action_line(line, print=false)
      meta_data = {}
      split_line = line.split(':')

      meta_data[:action] = split_line[0]
      meta_data[:chunk_number] split_line[1]
      meta_data[:hash_length] = split_line[2]
      meta_data[:chunk_length] = split_line[3].to_i

      meta_data[:chunk]  = f.read(meta_data[:chunk_length])
      # f iterator is now set for next chunk

      if print
        puts "Chunk ##{@s_chunk_count + @a_chunk_count}"
        puts "Action: #{meta_data[:action]}"
        puts "Chunk Number: #{meta_data[:chunk_number]}"
        puts "Hash Length: #{meta_data[:hash_length]}"
        puts "Chunk Length: #{meta_data[:chunk_length]}"
        #puts "Chuch Data:\n#{chunk}\nend"
      end

      meta_data
    end
end

