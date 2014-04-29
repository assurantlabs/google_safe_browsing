require 'spec_helper'

describe GoogleSafeBrowsing::Canonicalize do
  it 'should pass Units tests provided by Google' do
    [
     ['http://host/%25%32%35', 'http://host/%25'],
     ['http://host/%25%32%35%25%32%35', 'http://host/%25%25'],
     ['http://host/%2525252525252525', 'http://host/%25'],
     ['http://host/asdf%25%32%35asd', 'http://host/asdf%25asd'],
     ['http://host/%%%25%32%35asd%%', 'http://host/%25%25%25asd%25%25'],
     ['http://www.google.com/', 'http://www.google.com/'],
     ['http://%31%36%38%2e%31%38%38%2e%39%39%2e%32%36/%2E%73%65%63%75%72%65/%77%77%77%2E%65%62%61%79%2E%63%6F%6D/', 'http://168.188.99.26/.secure/www.ebay.com/'],
     ['http://195.127.0.11/uploads/%20%20%20%20/.verify/.eBaysecure=updateuserdataxplimnbqmn-xplmvalidateinfoswqpcmlx=hgplmcx/', 'http://195.127.0.11/uploads/%20%20%20%20/.verify/.eBaysecure=updateuserdataxplimnbqmn-xplmvalidateinfoswqpcmlx=hgplmcx/'],
     ['http://host%23.com/%257Ea%2521b%2540c%2523d%2524e%25f%255E00%252611%252A22%252833%252944_55%252B', 'http://host%23.com/~a!b@c%23d$e%25f^00&11*22(33)44_55+'],
     ['http://3279880203/blah', 'http://195.127.0.11/blah'],
     ['http://www.google.com/blah/..', 'http://www.google.com/'],
     ['www.google.com/', 'http://www.google.com/'],
     ['www.google.com', 'http://www.google.com/'],
     ['http://www.evil.com/blah#frag', 'http://www.evil.com/blah'],
     ['http://www.GOOgle.com/', 'http://www.google.com/'],
     ['http://www.google.com.../', 'http://www.google.com/'],
     ["http://www.google.com/foo\tbar\rbaz\n2", 'http://www.google.com/foobarbaz2'],
     ['http://www.google.com/q?', 'http://www.google.com/q?'],
     ['http://www.google.com/q?r?', 'http://www.google.com/q?r?'],
     ['http://www.google.com/q?r?s', 'http://www.google.com/q?r?s'],
     ['http://evil.com/foo#bar#baz', 'http://evil.com/foo'],
     ['http://evil.com/foo;', 'http://evil.com/foo;'],
     ['http://evil.com/foo?bar;', 'http://evil.com/foo?bar;'],
     ["http://\x01\x80.com/", 'http://%01%80.com/'],
     ['http://notrailingslash.com', 'http://notrailingslash.com/'],
     ['http://www.gotaport.com:1234/', 'http://www.gotaport.com:1234/'],
     ['  http://www.google.com/  ', 'http://www.google.com/'],
     ['http:// leadingspace.com/', 'http://%20leadingspace.com/'],
     ['http://%20leadingspace.com/', 'http://%20leadingspace.com/'],
     ['%20leadingspace.com/', 'http://%20leadingspace.com/'],
     ['https://www.securesite.com/', 'https://www.securesite.com/'],
     ['http://host.com/ab%23cd', 'http://host.com/ab%23cd'],
     ['http://host.com//twoslashes?more//slashes', 'http://host.com/twoslashes?more//slashes']
    ].each do |given, expected|
      expect(GoogleSafeBrowsing::Canonicalize.url(given)).to eq expected
    end
  end

  describe 'urls for lookup method' do
    it 'should returns an array of URLs for hashing and lookup from url with params' do
      url = 'http://a.b.c/1/2.html?param=1'
      urls = ['a.b.c/1/2.html?param=1',
              'a.b.c/1/2.html',
              'a.b.c/',
              'a.b.c/1/',
              'b.c/1/2.html?param=1',
              'b.c/1/2.html',
              'b.c/',
              'b.c/1/']

      expect(GoogleSafeBrowsing::Canonicalize.urls_for_lookup(url).sort).to \
        eq urls.sort
    end

    it 'should returns an array of URLs for hashing and lookup from url with many hosts' do
      url = 'a.b.c.d.e.f.g/1.html'
      urls = ['a.b.c.d.e.f.g/1.html',
              'a.b.c.d.e.f.g/',
              'c.d.e.f.g/1.html',
              'c.d.e.f.g/',
              'd.e.f.g/1.html',
              'd.e.f.g/',
              'e.f.g/1.html',
              'e.f.g/',
              'f.g/1.html',
              'f.g/']

      expect(GoogleSafeBrowsing::Canonicalize.urls_for_lookup(url).sort).to \
        eq urls.sort
    end
  end

  describe 'cart_prod method' do
    it 'should return the cartesian product of two arrays with concatination' do
      verbs = ['jump', 'climb', 'surf']
      suffixes = ['s', 'ed', 'ing']
      cart = ['jumps', 'jumped', 'jumping',
              'climbs', 'climbed', 'climbing',
              'surfs', 'surfed', 'surfing']
      expect(GoogleSafeBrowsing::Canonicalize.cart_prod(verbs, suffixes)).to \
        eq cart
    end
  end

  describe 'split host name method' do
    it 'should split a url into host and path components' do
      host = 'test.com'
      path = 'test/path/components.html'
      joined = { :host => host, :path => path }
      expect(
        GoogleSafeBrowsing::Canonicalize.split_host_path(host + '/' + path)
      ).to eq joined
    end
  end

  describe 'remove protocol' do
    it 'should remove the protocol when present' do
      host = 'test.url.com/'
      url = "http://#{host}"
      expect(GoogleSafeBrowsing::Canonicalize.remove_protocol(url)).to eq host
    end

    it 'should return the original string if no protocol present' do
      host = 'test.url.com/'
      expect(GoogleSafeBrowsing::Canonicalize.remove_protocol(host)).to eq host
    end
  end

  describe 'remove port method' do
    it 'should remove the port when present' do
      host = 'test.url.com/'
      url = "#{host}:8000"
      GoogleSafeBrowsing::Canonicalize.remove_port(url).should eq host
    end

    it 'should return the original string if no port present' do
      host = 'test.url.com/'
      GoogleSafeBrowsing::Canonicalize.remove_port(host).should eq host
    end
  end

  describe 'remove username and password method' do
    it 'should remove the username and password when present' do
      host = 'test.url.com/'
      url = "tester:pa55word@#{host}"
      GoogleSafeBrowsing::Canonicalize.
        remove_username_and_password(url).should eq host
    end

    it 'should return the original string if no username/password present' do
      host = 'test.url.com/'
      GoogleSafeBrowsing::Canonicalize.
        remove_username_and_password(host).should eq host
    end
  end

  describe 'fixing invalid hosts' do
    it 'should return nil for local IP Addresses' do
      host = '192.168.1.1'
        GoogleSafeBrowsing::Canonicalize.fix_host(host).should eq host
    end
    it 'should return nil regardless of creds or port' do
      host = 'what:beef@192.168.1.1:3000'
        GoogleSafeBrowsing::Canonicalize.fix_host(host).should eq host
    end
  end
end
