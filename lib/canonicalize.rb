require 'uri'
require 'ip'

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
    if cann.index(PROTOCOL_DELIMITER)
      delimiting_index = cann.index(PROTOCOL_DELIMITER)
      @protocol = cann[0..delimiting_index-1]
      protocol_end_index = delimiting_index + PROTOCOL_DELIMITER.length
      cann = cann[protocol_end_index..-1]
    end

    #split into host and path components
    split_point = cann.index('/')
    if split_point
      host = cann[0..split_point-1]
      path = cann[split_point+1..-1]
    else
      host = cann
      path = ''
    end
    #puts "Host: #{host}"
    #puts "Path: #{path}"
    #puts "Fixed Path: #{fix_path path}"

    cann = fix_host( host ) + '/' + fix_path( path )

    # add leading protocol
    @protocol ||= DEFAULT_PROTOCOL
    cann = @protocol + PROTOCOL_DELIMITER + cann

    strict_escape(cann)
  end

  private

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

end
