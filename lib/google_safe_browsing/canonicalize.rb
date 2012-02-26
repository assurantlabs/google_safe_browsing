require 'uri'
require 'ip'
require File.dirname(__FILE__) + '/top_level_domain.rb'

module GoogleSafeBrowsing
  class Canonicalize

    PROTOCOL_DELIMITER = '://'
    DEFAULT_PROTOCOL = 'http'

    def self.url(raw_url)
      #puts raw_url
      #remove tabs, carriage returns and line feeds
      raw_url.gsub!("\t",'')
      raw_url.gsub!("\r",'')
      raw_url.gsub!("\n",'')

      cann = raw_url.clone
      cann.gsub!(/\A\s+|\s+\Z/, '')

      cann = remove_fragment(cann)

      # repeatedly unescape until no more escaping
      cann = recursively_unescape(cann)

      # remove leading PROTOCOL
      cann = remove_protocol(cann)

      #split into host and path components
      splits = split_host_path(cann)
      cann = fix_host( splits[:host] ) + '/' + fix_path( splits[:path] )

      # add leading protocol
      @protocol ||= DEFAULT_PROTOCOL
      cann = @protocol + PROTOCOL_DELIMITER + cann

      strict_escape(cann)
    end

    def self.urls_for_lookup(lookup_url)
      lookup_url = url(lookup_url)

      lookup_url = remove_protocol(lookup_url)

      splits = split_host_path(lookup_url)

      host_strings = [splits[:host]]
      host = TopLevelDomain.split_from_host(splits[:host]).last(5)
      ( host.length - 1 ).times do 
        host_strings << host.join('.')
        host.shift
      end
      host_strings.uniq!

      path_split = splits[:path].split('?')
      path = path_split[0]
      params = path_split[1]


      path_strings = [ splits[:path], '/' ]
      if path
        path_strings << path
        paths_to_append = path.split('/').first(3)
        paths_to_append.length.times do
          path_strings << paths_to_append.join('/')
          paths_to_append.pop
        end
      end
      #puts path_strings
      path_strings.map!{ |p| '/' + p }
      path_strings.map!{ |p| p + '/' unless p[-1..-1] == '/' }
      path_strings.uniq!.compact!

      #puts host_strings.length
      #puts path_strings.length

      
      ( cart_prod(host_strings, path_strings) + host_strings ).uniq
    end

    private

      def self.cart_prod(a_one, a_two)
        result = []
        a_one.each do |i|
          a_two.each do |j|
            result << "#{i}#{j}"
          end
        end
        result
      end

      def self.split_host_path(cann)
        ret= { :host => cann, :path => '' }
        split_point = cann.index('/')
        if split_point
          ret[:host] = cann[0..split_point-1]
          ret[:path] = cann[split_point+1..-1]
        end

        ret
      end

      def self.remove_fragment(string)
        string = string[0..string.index('#')-1] if string.index('#')
        string
      end

      def self.recursively_unescape(url)
        compare_url = url.clone 
        url = URI.unescape(url)
        while(compare_url != url)
          compare_url = url.clone
          url = URI.unescape(url)
        end
        url
      end

      def self.fix_host(host)
        #puts "In Host: #{host}"
        # remove leading and trailing dots, multiple dots to one
        host.gsub!(/\A\.+|\.+\Z/, '')
        host.gsub!(/\.+/, '.')

        host.downcase!

        host = IP::V4.new(host.to_i).to_s if host.to_i > 256

        host
      end

      def self.fix_path(path)
        #puts "In Path: #{path}"

        #remove leading slash
        path = path[1..-1] if path[0..0] == '/'

        preserve_trailing_slash = ( path[-1..-1] == '/' )

        if path.index('?')
          first_ques = path.index('?')
          params = path[first_ques..-1]
          path = path[0..first_ques-1]
        end

        # remove multiple '/'
        path.gsub!(/\/+/, '/')

        new_path_array = []
        path.split('/').each do |p|
          new_path_array << p unless p == '.' || p == '..'
          new_path_array.pop if p == '..'
        end

        path = new_path_array.join('/')
        path += '/' if preserve_trailing_slash
        path += params if params

        path
      end

      def self.strict_escape(url)
        url = URI.escape url

        # unescape carat, may need other optionally escapeable chars
        url.gsub!('%5E','^')

        url
      end

      def self.remove_protocol(cann)
        if cann.index(PROTOCOL_DELIMITER)
          delimiting_index = cann.index(PROTOCOL_DELIMITER)
          @protocol = cann[0..delimiting_index-1]
          protocol_end_index = delimiting_index + PROTOCOL_DELIMITER.length
          cann = cann[protocol_end_index..-1]
        end
        cann
      end
  end
end
