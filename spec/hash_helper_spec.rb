require 'spec_helper'

describe GoogleSafeBrowsing::HashHelper do
  describe GoogleSafeBrowsing::HashHelper::GsbHash do
    it 'should take a hash string upon instantiation' do
      expect { GoogleSafeBrowsing::HashHelper::GsbHash.new('123456') }.not_to raise_error
    end

    it 'should return the first 8 characters as the prefix' do
      hash = '1234567891011'
      prefix = hash[0..7]
      gsb_hash = GoogleSafeBrowsing::HashHelper::GsbHash.new(hash)
      expect(gsb_hash.prefix).to eq prefix
    end

    it 'should return the whole hash on string conversion' do
      hash = '1234567891011'
      gsb_hash = GoogleSafeBrowsing::HashHelper::GsbHash.new(hash)
      expect("#{gsb_hash}").to eq hash
    end
  end

  describe 'converting an array of url strings to an array of GsbHashes' do
    input = [ 'malware.test.org', 'mobiledefense.com', 'also.this.domain' ]
    GoogleSafeBrowsing::HashHelper.urls_to_gsb_hashes(input).each do |hash|
      specify { expect(hash.class).to eq GoogleSafeBrowsing::HashHelper::GsbHash }
    end
  end

  describe 'converting an array of raw hashes to an array of GsbHashes' do
    input = [ '0015e260740a3963c724be95f966c6063077979c',
              '001717460c5ba78085eee9b7ed58bec94759e4c8',
              '001fa1574a73e9a8481e26df2aa6104eb2406b57'
            ]
    GoogleSafeBrowsing::HashHelper.raw_to_gsb_hashes(input).each do |hash|
      specify { expect(hash).to be_a GoogleSafeBrowsing::HashHelper::GsbHash }
    end
  end
end
