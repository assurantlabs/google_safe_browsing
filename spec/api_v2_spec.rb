require 'spec_helper'

describe GoogleSafeBrowsing::APIv2 do
  describe '#lookup' do
    it 'returns nil for invalid urls' do
      expect(GoogleSafeBrowsing::APIv2.lookup('asdlkfjasd;l')).to be_nil
    end
  end

  describe '#lookup_url_hashes' do
    it 'returns nil for empty hashes' do
      expect(GoogleSafeBrowsing::APIv2.lookup_url_hashes(Array.new)).to be_nil
    end
  end
end
