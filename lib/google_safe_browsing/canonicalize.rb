require 'uri'
require 'ip'
require File.dirname(__FILE__) + '/top_level_domain.rb'

module GoogleSafeBrowsing
  # Helpers to Canonicalize urls and generate url permutations for lookups
  class Canonicalize

    PROTOCOL_DELIMITER = '://'
    DEFAULT_PROTOCOL = 'http'

    # Base Canonicalizer method
    #
    # @param (String) uncanonicalized url string
    # @return (String) canonicalized url string
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

    # Generate the url permutations for lookup
    #
    # @param (String) lookup_url uncanonicalized url string
    # @return (Array) array of cannonicalized url permutation strings
    def self.urls_for_lookup(lookup_url)
      lookup_url = url(lookup_url)

      lookup_url = remove_protocol(lookup_url)

      splits = split_host_path(lookup_url)

      host_string = strip_username_password_and_port_from_host(splits[:host])

      #return empty array unless host_string has at least one period
      return [] unless host_string.include?('.')

      host_strings = [host_string]
      host = TopLevelDomain.split_from_host(host_string).last(5)
      ( host.length - 1 ).times do 
        host_strings << host.join('.')
        host.shift
      end
      host_strings.uniq!

      path_strings = generate_path_strings(splits[:path])

      cart_prod(host_strings, path_strings)
    end

   # private

      # Generates the path permutations from the raw path string
      #
      # @param (String) raw_path path split from the full url string
      # @return (Array) array of path permutation strings
      def self.generate_path_strings(raw_path)
        return [ '/', '' ] if raw_path == ''

        path_split = raw_path.split('?')
        path = path_split[0] || ''
        params = path_split[1] || ''


        path_components = path.split('/').first(3)
        path_strings = [ '/' ]
        path_components.length.times do
          path_strings << '/' + path_components.join('/')
          path_components.pop
        end

        path_strings.map! do |p|
          unless p.index('.')
            p + '/'
          else
            p
          end
        end
        path_strings.map!{ |p| p.to_s.gsub!(/\/+/, '/') }
        path_strings.compact!
        path_strings.uniq!

        unless params.blank?
          path_strings | path_strings.map do |p|
            if p[-1] == '/'
              p
            else
              "#{p}?#{params}"
            end
          end
        else
          return path_strings
        end
      end

      # Returns the cartesian product of two arrays by concatination of the string representation of the elements
      #
      # @param (Array) a_one array of strings
      # @param (Array) a_two array of strings
      # @return (Array) cartesian product of arrays with elements concatinated
      def self.cart_prod(a_one, a_two)
        result = []
        a_one.each do |i|
          a_two.each do |j|
            result << "#{i}#{j}"
          end
        end
        result
      end

      # Takes the canonicalized url and splits the host and the path apart
      #
      # @param (String) cann canonicalized url string
      # @return (Hash) !{ :host => host_part, :path => path_part }
      def self.split_host_path(cann)
        ret= { :host => cann, :path => '' }
        split_point = cann.index('/')
        if split_point
          ret[:host] = cann[0..split_point-1]
          ret[:path] = cann[split_point+1..-1]
        end

        ret
      end

      # Strips the fragment portion of the url string (the last '#' and everything after)
      #
      # @param (String) string url
      # @return (String) parameter with the fragment removed
      def self.remove_fragment(string)
        string = string[0..string.index('#')-1] if string.index('#')
        string
      end

      # Continues to unescape the url until unescaping has no effect
      #
      # @param (String) url url string
      # @return (String) fully unescaped url string
      def self.recursively_unescape(url)
        compare_url = url.clone 
        url = URI.unescape(url)
        while(compare_url != url)
          compare_url = url.clone
          url = URI.unescape(url)
        end
        url
      end

      # Apply initial fixes to host string
      #
      # @param (String) host host string
      # @return (String) standardized host string
      def self.fix_host(host)
        #puts "In Host: #{host}"
        # remove leading and trailing dots, multiple dots to one
        host.gsub!(/\A\.+|\.+\Z/, '')
        host.gsub!(/\.+/, '.')

        host.downcase!

        if host =~ /^\d+$/
          host = IP::V4.new(host.to_i).to_addr
        elsif host =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
          host = IP.new(host).to_addr 
        end

        host
      end

      # Apply initial fixes to path string
      #
      # @param (String) path path string
      # @return (String) standardized path string
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

      # Escape the url, but do not escape certain characters; such as the carat
      #
      # @param (String) url url string
      # @return (String) escaped url string
      def self.strict_escape(url)
        url = URI.escape url

        # unescape carat, may need other optionally escapeable chars
        url.gsub!('%5E','^')

        url
      end

      # Strip the leading protocol from the url string
      #
      # @param (String) cann url string
      # @return (String) url string without the protocol
      def self.remove_protocol(cann)
        if cann.index(PROTOCOL_DELIMITER)
          delimiting_index = cann.index(PROTOCOL_DELIMITER)
          @protocol = cann[0..delimiting_index-1]
          protocol_end_index = delimiting_index + PROTOCOL_DELIMITER.length
          cann = cann[protocol_end_index..-1]
        end
        cann
      end

      # Strip the user name, password and port number from the url
      #
      # @param (String) host_string host portion of the url
      # @return (String) host portion of the url without the username, password and port
      def self.strip_username_password_and_port_from_host(host_string)
        host_string = remove_port(host_string)
        remove_username_and_password(host_string)
      end

      # Strip port number from host string
      #
      # @param (see strip_username_password_and_port_from_host)
      # @return (String) host part without the port number
      def self.remove_port(host_string)
        port_sep = host_string.rindex(':')
        if port_sep
          host_string[0..port_sep-1]
        else
          host_string
        end
      end

      # Strip user name and password from host part of url
      #
      # @param (see remove_port)
      # @return (String) host part of url without user name or password
      def self.remove_username_and_password(host_string)
        un_sep = host_string.index('@')
        if un_sep
          host_string[un_sep+1..-1]
        else
          host_string
        end
      end
  end
end
