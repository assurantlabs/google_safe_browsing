require 'spec_helper'

describe GoogleSafeBrowsing::APIv2 do
  describe 'lookup' do
    it 'should return nil for invalid urls' do
      expect(GoogleSafeBrowsing::APIv2.lookup('asdlkfjasd;l')).to be_nil
    end
  end
end
