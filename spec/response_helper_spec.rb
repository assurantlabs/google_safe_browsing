require 'spec_helper'

describe GoogleSafeBrowsing::ResponseHelper do
  describe 'parse_data_line' do
    it 'should split the data line correctly for add chunks' do
      expected = {}
      expected[:action] = 'a'
      expected[:chunk_number] = 123
      expected[:hash_length] = 4
      expected[:chunk_length] = 122

      test_line = "#{expected[:action]}:#{expected[:chunk_number]}:" +
      "#{expected[:hash_length]}:#{expected[:chunk_length]}\n"

      GoogleSafeBrowsing::ResponseHelper.parse_data_line(test_line).should== expected
    end
  end

    describe 'parse_data_response' do
      it 'should parse a multiline string into a hash containing delay seconds and data redirect urls' do
        expected = {}
        expected[:delay_seconds] = 60
        expected[:lists] = [ 'googpub-phish-shavar', 'goog-malware-shavar' ]
        expected[:data_urls] = Hash.new()
        expected[:data_urls]['googpub-phish-shavar'] = []
        expected[:data_urls]['googpub-phish-shavar'] << 'example.com/1234'
        expected[:data_urls]['googpub-phish-shavar'] << 'example.com/54321'
        expected[:data_urls]['goog-malware-shavar'] = []
        expected[:data_urls]['goog-malware-shavar'] << 'example.com/1234'
        expected[:data_urls]['goog-malware-shavar'] << 'example.com/54321'

        test_data = "n:#{expected[:delay_seconds]}\n"
        expected[:lists].each do |list|
          test_data += "i:#{list}\n"
          expected[:data_urls][list].each do |url|
            test_data += "u:#{url}\n"
          end
        end
        GoogleSafeBrowsing::ResponseHelper::parse_data_response(test_data).should== expected
      end
    end
end
