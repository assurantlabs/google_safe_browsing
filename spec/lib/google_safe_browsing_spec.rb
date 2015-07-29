require 'spec_helper'

describe GoogleSafeBrowsing do

  describe 'friendly list name conversion' do
    it 'should take goog-malware-shavar and return malware' do
      expect(GoogleSafeBrowsing.friendly_list_name('goog-malware-shavar')).to eq 'malware'
    end

    it 'should take googpub-phish-shavar and return phishing' do
      expect(GoogleSafeBrowsing.friendly_list_name('googpub-phish-shavar')).to eq 'phishing'
    end
  end

end
