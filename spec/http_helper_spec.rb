require 'spec_helper'

describe GoogleSafeBrowsing::HttpHelper do

  it 'should build URIs' do
    @action = 'downloads'
    @expected = URI("http://safebrowsing.clients.google.com/safebrowsing/downloads?client=api&apikey=&appver=#{GoogleSafeBrowsing.config.app_ver}&pver=2.2")
    GoogleSafeBrowsing::HttpHelper.uri_builder(@action).should== @expected
  end

  it 'should encode HTTP parameters' do
    @expected = "?client=api&apikey=&appver=#{GoogleSafeBrowsing.config.app_ver}&pver=2.2"
    GoogleSafeBrowsing::HttpHelper.encoded_params.should== @expected
  end

end
