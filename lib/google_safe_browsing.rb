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
  CURRENT_LISTS = [ 'googpub-phish-shavar', 'goog-malware-shaver' ]

  def update
    data_response = get_data

    to_do_array = parse_data_response(data_response)

    delay(to_do_array[:delay_seconds])

    to_do_array[:data_urls].each do |url|
      receive_data('http://' + url)
    end

  end

  def delay(delay_seconds)
    puts "Google told us to wait for #{delay_seconds} seconds"
    puts "We will wait...."
    start_time = Time.now
    while(start_time + delay_seconds > Time.now)
        puts "#{(delay_seconds - (Time.now - start_time)).to_i}..."
        sleep(10)
    end
    puts "Thank you for being patient"
  end

  def parse_data_line(line)
    split_line = line.split(':')

    ret[ :action ]        = split_line[0]
    ret[ :chunk_number ]  = split_line[1]
    ret[ :hash_length ]   = split_line[2]
    ret[ :chunk_length ]  = split_line[3].to_i

   #puts "Chunk ##{s_chunk_count + a_chunk_count}"
   #puts "Action: #{action}"
   #puts "Chunk Number: #{split_line[1]}"
   #puts "Hash Length: #{hash_length}"
   #puts "Chunk Length: #{chunk_length}"
   ##puts "Chuch Data:\n#{chunk}\nend"
  end

  def receive_data(url)
    open(url) do |f|
      while(line = f.gets)
        line_actions = parse_data_line(line)

        chunk  = f.read(line_actions[:chunk_length])
        # f iterator is now set for next chunk

        if line_actions[:chunk_length] == 0
          puts "No Chunk Here, move along"
          next
        end

        chunk_iterator = chunk.bytes
        host_key = four_as_hex( read_bytes_from(chunk_iterator, 4) )
        count = chunk_iterator.next

        case action
        when 's'
          sub_chunk(chunk_iterator, count, line_actions[:hash_length], host_key)
        when 'a'
          add_chunk(chunk_iterator, count, line_actions[:hash_length], host_key)
        else
          puts "neither a nor s ======================================================="
        end
      end
    end
  end

  def add_chunk(chunk_iterator, count, hash_length, host_key)
    if count == 0

      # all urls under host are a match
      # TODO how to implement that
    else
      count.times do |i|
        prefix = read_bytes_from(chunk_iterator, hash_length)
        puts "  with this prefix: #{four_as_hex( prefix )}"
      end
    end
  end

  def sub_chunk(chunk_iterator, count, hash_length, host_key)
    chunk_num = read_bytes_from(chunk_iterator, 4)
    if count == 0
      puts "Sub this chunk number: #{four_as_network_order_int( chunk_num )}"
    else
      count.times do |i|
        puts " #{i } chunk number to remove: #{four_as_network_order_int( chunk_num )}"
        prefix = read_bytes_from(chunk_iterator, hash_length)
        puts "  with this prefix: #{four_as_hex( prefix )}"
      end
    end
  end

  def get_lists
    uri = uri_builder('list')
    lists = Net::HTTP.get(uri).split("\n")
  end

  def get_data(list=nil)
    # Get (via Post) List Data
    uri = uri_builder('downloads')
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = build_chunk_list(list)

    response = Net::HTTP.start(uri.host) { |http| http.request request }
  end

  def parse_data_response(response)
    data_urls = []
    response.body.split("\n").each do |line|
      vals = line.split(':')
      case vals[0]
      when 'n'
        delay_seconds = vals[1].to_i
      when 'u'
        data_urls << vals[1]
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
    ret[:delay_seconds] = delay_seconds
    ret[:data_urls] = data_urls
  end

    def build_chunk_list(list=nil)
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

    def uri_builder(action)
      URI("#{HOST}/#{action}#{encode_www_form(PARAMS)}")
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
end
