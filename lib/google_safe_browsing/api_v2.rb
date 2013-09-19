module GoogleSafeBrowsing
  # Main Interface for Module
  class APIv2
    # Completes an update
    #
    # @return (Integer) the number of seconds before this method should be called again
    def self.update
      HttpHelper.get_keys unless GoogleSafeBrowsing.config.have_keys?

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

      gsb_hashes = HashHelper.urls_to_gsb_hashes(urls)
      lookup_gsb_hashes(gsb_hashes)
    end

    # Performs a lookup of the given SHA256 url hashes
    #
    # @param (Array) SHA256 url hashes array to be looked up
    # @return (String, nil) the friendly list name if found, or 'nil'
    def self.lookup_url_hashes(raw_hashes)
      return nil if raw_hashes.empty?

      gsb_hashes = HashHelper.raw_to_gsb_hashes(raw_hashes)
      lookup_gsb_hashes(gsb_hashes)
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

    private

      def self.lookup_gsb_hashes(gsb_hashes)
        raw_hash_array = gsb_hashes.map(&:to_s)
        full_hash_hits = FullHash.where(full_hash: raw_hash_array).first

        if full_hash_hits
          return GoogleSafeBrowsing.friendly_list_name(full_hash_hits.list)
        end

        prefixes_needing_lookup = unsafe_prefixes(gsb_hashes) - safe_prefixes(gsb_hashes)

        return lookup_prefixes(prefixes_needing_lookup) if prefixes_needing_lookup.any?
        return nil
      end

      def self.unsafe_prefixes(gsb_hashes)
        get_prefix_list(AddShavar, gsb_hashes)
      end

      def self.safe_prefixes(gsb_hashes)
        get_prefix_list(SubShavar, gsb_hashes)
      end

      def self.get_prefix_list(klass, gsb_hashes)
        prefixes = gsb_hashes.map { |h| h.prefix }
        klass.where(prefix: prefixes).map { |s| [ s.list, s.prefix ] }
      end

      def self.lookup_prefixes(prefixes)
        full_hashes = HttpHelper.request_full_hashes(prefixes.map { |p| p[1] })

        # save hashes first
        # cannot return early because all FullHashes need to be saved
        hit_list = nil
        full_hashes.each do |hash|
          FullHash.create!(list: hash[:list],
                           add_chunk_number: hash[:add_chunk_num],
                           full_hash: hash[:full_hash])

          hit_list = hash[:list] if raw_hash_array.include?(hash[:full_hash])
        end

        GoogleSafeBrowsing.friendly_list_name(hit_list)
      end
  end
end
