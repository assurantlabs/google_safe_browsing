require 'spec_helper'

describe GoogleSafeBrowsing do

  describe 'friendly list name conversion' do
    it 'should take goog-malware-shavar and return malware' do
      GoogleSafeBrowsing.friendly_list_name('goog-malware-shavar').should== 'malware'
    end

    it 'should take googpub-phish-shavar and return phishing' do
      GoogleSafeBrowsing.friendly_list_name('googpub-phish-shavar').should== 'phishing'
    end
  end

end
