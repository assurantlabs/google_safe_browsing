module GoogleSafeBrowsing
  class TopLevelDomain

    def self.from_host(host)
      components = host.split('.')

      tlds = parse_tld_to_hash

      tld = components.pop
      components.reverse.each do |comp|
        next_tld = "#{comp}.#{tld}"

        if tlds[next_tld]
          tld = next_tld
        else
          break
        end
      end

      tld
    end

    def self.split_from_host(host)
      components = host.split('.')

      tlds = parse_tld_to_hash

      next_tld = components[-2..-1].join('.')
      while tlds[next_tld]
        tmp = components.pop
        components[-1] = components.last + '.' + tmp
        next_tld = components[-2..-1].join('.')
      end

      components
    end


    private 

    def self.parse_tld_to_hash
      hash = Hash.new(nil)
      f = File.open(File.dirname(__FILE__) + '/effective_tld_names.dat.txt', 'r')
      while(line = f.gets)
        hash[line.chomp] = true unless line[0..1] == '//'
      end
      hash
    end
  end
end
