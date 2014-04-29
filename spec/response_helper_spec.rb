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
      expected[:lists] = ['googpub-phish-shavar', 'goog-malware-shavar']
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

    context 'with chunks to delete' do
      let(:response) do
        <<-RESP.strip_heredoc
          m:OQnycd29T2amitNycTNkwVUEE7Q=\n
          n:1916\n
          i:goog-malware-shavar\n
          ad:135756-135792\n
          sd:130219-130245\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChNnb29nLW1hbHdhcmUtc2hhdmFyEAEYl6AIIKCgCDIGFxACAP8D,UF2ayGmdmJqP4vaGC6sHjb7tUmk=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChNnb29nLW1hbHdhcmUtc2hhdmFyEAEYoaAIIMChCCoTURACAP__________________ADILIRACAP_______wA,cxq6RZZ6I3FZXbfFQrlRh4FuwqE=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChNnb29nLW1hbHdhcmUtc2hhdmFyEAAY2csIIOzLCDIH2SUCAP__Dw,DktRK6XzCLTZ8KQerywgAm3Rpmk=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChNnb29nLW1hbHdhcmUtc2hhdmFyEAAY7csIIIDMCDIH7SUCAP__Dw,uaaKeiyrdW3bAsa-uVCW9Ahh4Sg=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChNnb29nLW1hbHdhcmUtc2hhdmFyEAAYgcwIIIDgCCq-AjUmAgD_________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________DzILASYCAN-___j__w8,7L3clEO2ZMELIjRLvI8-Aa-sEYk=\n
          i:googpub-phish-shavar\n
          ad:273892-273952\n
          sd:15776-15777\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChRnb29ncHViLXBoaXNoLXNoYXZhchABGIGCASCAjAEqjwGwQQAA________________________________________________________________________________________________________________________________________________________________________________________ATIaAUEAAP___________________________38,fXo0ait1JwQqZt--twInvpXAgxg=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChRnb29ncHViLXBoaXNoLXNoYXZhchAAGPGjESDApBEyD_FRBAD_____________AA,81On4-H4Hs8VBNliocNoU2ar2pk=\n
          u:safebrowsing-cache.google.com/safebrowsing/rd/ChRnb29ncHViLXBoaXNoLXNoYXZhchAAGMGkESCApxEqIaFSBAD_____________________________________ADIRQVIEAP_______________wA,cUoyC8iANkH4pyYSXRz_bNvRHOI=\n
        RESP
      end

      it 'should not crash' do
        GoogleSafeBrowsing::ResponseHelper::parse_data_response(response)
      end
    end
  end
end
