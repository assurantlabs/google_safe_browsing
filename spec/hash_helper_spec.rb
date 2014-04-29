require 'spec_helper'

describe GoogleSafeBrowsing::HashHelper do
  describe GoogleSafeBrowsing::HashHelper::GsbHash do
    it 'should take a hash string upon instantiation' do
      lambda { GoogleSafeBrowsing::HashHelper::GsbHash.new('123456') }.should_not raise_error
    end

    it 'should return the first 8 characters as the prefix' do
      hash = '1234567891011'
      prefix = hash[0..7]
      GoogleSafeBrowsing::HashHelper::GsbHash.new(hash).prefix.should eq prefix
    end

    it 'should retrun the whole hash on string conversion' do
      hash = '1234567891011'
      "#{ GoogleSafeBrowsing::HashHelper::GsbHash.new(hash) }".should eq hash
    end
  end

  describe '#usls_to_hashes' do
    it 'converts an array of url strings to an array of GsbHashes' do
      input = ['malware.test.org', 'mobiledefense.com', 'also.this.domain']
      GoogleSafeBrowsing::HashHelper.urls_to_hashes(input).each do |expected|
        expect(expected).to be_a(GoogleSafeBrowsing::HashHelper::GsbHash)
      end
    end
  end
end
