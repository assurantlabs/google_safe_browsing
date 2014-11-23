require 'spec_helper'

describe GoogleSafeBrowsing::APIv3 do
  describe 'lookup' do
    it 'should return nil for invalid urls' do
      GoogleSafeBrowsing::APIv3.lookup('asdlkfjasd;l').should be_nil
    end
  end
end
