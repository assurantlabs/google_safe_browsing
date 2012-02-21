require 'spec_helper'

describe GoogleSafeBrowsing do
  describe GoogleSafeBrowsing::APIv2 do
    describe 'update' do
    end

   #describe 'delay' do
   #  it 'should stop execution for specified number of seconds' do
   #    start_time = Time.now
   #    seconds_delay = 3
   #    GoogleSafeBrowsing::APIv2::delay(seconds_delay)
   #    Time.now.should >= start_time + seconds_delay
   #  end
   #end

    describe 'parse_data_line' do
      it 'should split the data line correctly for add chunks' do
        expected = {}
        expected[:action] = 'a'
        expected[:chunk_number] = 123
        expected[:hash_length] = 4
        expected[:chunk_length] = 122

        test_line = "#{expected[:action]}:#{expected[:chunk_number]}:" +
          "#{expected[:hash_length]}:#{expected[:chunk_length]}\n"

        GoogleSafeBrowsing::APIv2::parse_data_line(test_line).should== expected
      end
    end

    describe 'receive_data' do
      #look up how to mock http requests
    end

    describe 'add_chunk' do
    end

    describe 'sub_chunk' do
    end

    describe 'get_lists' do
    end

    describe 'get_data' do
    end

    describe 'parse_data_response' do
      it 'should parse a multiline string into a hash containing delay seconds and data redirect urls' do
        expected = {}
        expected[:delay_seconds] = 60
        expected[:lists] = [ 'googpub-phish-shavar', 'goog-malware-shavar' ]
        expected[:data_urls] = Hash.new([])
        expected[:data_urls]['googpub-phish-shavar'] << 'example.com/1234'
        expected[:data_urls]['googpub-phish-shavar'] << 'example.com/54321'
        expected[:data_urls]['goog-malware-shavar'] << 'example.com/1234'
        expected[:data_urls]['goog-malware-shavar'] << 'example.com/54321'

        test_data = "n:#{expected[:delay_seconds]}\n"
        expected[:lists].each do |list|
          test_data += "i:#{list}\n"
          expected[:data_urls][list].each do |url|
            test_data += "u:#{url}\n"
          end
        end
        GoogleSafeBrowsing::APIv2::parse_data_response(test_data).should== expected
      end
    end

    describe 'url_builder' do
    end

    describe 'encode_www_form' do
      it 'should convert a hash into a url params serialization' do
        expected = "?keytwo=val2&key=val"
        GoogleSafeBrowsing::APIv2::encode_www_form({ :key => 'val', :keytwo => 'val2' }).should== expected
      end
    end

    describe 'four_as_hex' do
      it 'should take four bytes and unpack them into hex' do
        GoogleSafeBrowsing::APIv2::four_as_hex('abcd').should== '16263646'
      end
    end

    describe 'four_as_network_order_int' do
      it 'should take four bytes and return them as a network order integer' do
        GoogleSafeBrowsing::APIv2::four_as_network_order_int('abcd').should== 1633837924
      end
    end

    describe 'read_bytes_from' do
    end
  end
end

