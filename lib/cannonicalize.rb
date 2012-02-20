require 'uri'

class Cannonicalize

  def self.url(raw_url)
    #remove tabs, carriage returns and line feeds
    raw_url.gsub!("\t",'')
    raw_url.gsub!("\r",'')
    raw_url.gsub!("\n",'')

    cann = raw_url.clone
    # strip ending hash value
    cann = cann[0..cann.rindex('#')-1] if cann.rindex('#')

    # repeatedly unescape until no more escaping
    cann = URI.unescape(raw_url)
    while(cann != raw_url)
      raw_url = cann.clone
      cann = URI.unescape(raw_url)
    end
  

    #split into host and path components
    split_point = cann.index('/')
    host = cann[0..split_point]
    path = cann[split_point-1..-1]

    #host cleaners
    # remove leading and trailing dots, multiple dots to one
    host = host.chomp('.')
    host.gsub!(/\.+/, '.')

    cann.downcase!

    #path cleaners
    path.gsub!(/\/+/, '/')

    split = path.split('/')
  
    new_path_array = []
    split.each do |p|
      unless p == '' || p == '.' || p == '..'
        new_path_array << p
      end
      new_path_array.pop if p == '..'
    end

    # add starting http://
    protocol = 'http://'
    cann = protocol + cann unless cann[0..6] == protocol
    cann += '/' unless cann[-1..-1] == '/'

    cann
  end
end
