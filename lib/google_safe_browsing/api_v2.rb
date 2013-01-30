module GoogleSafeBrowsing
  # Main Interface for Module
  class APIv2
    # Completes an update
    #
    # @return (Integer) the number of seconds before this method should be called again
    def self.update
      HttpHelper.rekey if GoogleSafeBrowsing.config.needs_rekey?

      data_response = HttpHelper.get_data

      to_do_array = ResponseHelper.parse_data_response(data_response.body)

      to_do_array[:lists].each do |list|
        to_do_array[:data_urls][list].each do |url|
          puts "#{list} - #{url}\n"
          ResponseHelper.receive_data('http://' + url, list)
        end
      end
      to_do_array[:delay_seconds]
    end

    # Performs a lookup of the given url
    #
    # @param (String) url a url string to be looked up
    # @return (String, nil) the friendly list name if found, or `nil`
    def self.lookup(url)
      urls = Canonicalize.urls_for_lookup(url.force_encoding('ASCII-8BIT'))
      return nil if urls.empty?

      hashes = HashHelper.urls_to_hashes(urls)
      raw_hash_array = hashes.collect{ |h| h.to_s }

      if full = FullHash.where(:full_hash => raw_hash_array).first
        return GoogleSafeBrowsing.friendly_list_name(full.list)
      end

      hits =  AddShavar.where(:prefix => hashes.map{|h| h.prefix}).collect{ |s| [ s.list, s.prefix ] }
      safes = SubShavar.where(:prefix => hashes.map{|h| h.prefix}).collect{ |s| [ s.list, s.prefix ] }

      reals = hits - safes

      if reals.any?
        full_hashes = HttpHelper.request_full_hashes(reals.collect{|r| r[1] })

        # save hashes first
        # cannot return early because all FullHashes need to be saved
        hit_list = nil
        full_hashes.each do |hash|
          FullHash.create!(:list => hash[:list], :add_chunk_number => hash[:add_chunk_num],
                                       :full_hash => hash[:full_hash])

          hit_list = hash[:list] if raw_hash_array.include?(hash[:full_hash])
        end
        return GoogleSafeBrowsing.friendly_list_name(hit_list)
      end
      nil
    end

    # Can be used to force a delay into a script running updates
    #
    # @param (Integer) delay_seconds the number of seconds to delay, should be the return value of {update}
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
  end
end
