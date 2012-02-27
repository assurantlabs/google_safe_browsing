module GoogleSafeBrowsing
  class APIv2
    def self.update
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

    def self.lookup(url)
      urls = Canonicalize.urls_for_lookup(url)

      hashes = HashHelper.urls_to_hashes(urls)


      if full = FullHash.where(:full_hash => hashes.collect{ |h| h.to_s }).first
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

          hit_list = hash[:list] if hashes.include?(hash[:full_hash])
        end
        return GoogleSafeBrowsing.friendly_list_name(hit_list)
      end
      nil
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
  end
end
