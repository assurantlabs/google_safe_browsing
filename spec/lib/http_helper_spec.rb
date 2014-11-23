require 'spec_helper'
require 'ostruct'

class StubResponse < Struct.new(:body); end

describe GoogleSafeBrowsing::HttpHelper do
  let(:encoded_params) { "?client=api&apikey=#{GoogleSafeBrowsing.config.api_key}&appver=#{GoogleSafeBrowsing.config.app_ver}&pver=3.0" }

  describe '.uri_builder' do
    let(:action) { 'downloads' }

    it 'builds URIs from actions' do
      expected = URI("#{GoogleSafeBrowsing.config.host}/#{action}#{encoded_params}")
      GoogleSafeBrowsing::HttpHelper.uri_builder(action).should == expected
    end

    it 'builds https URIs from actions' do
      GoogleSafeBrowsing::HttpHelper.uri_builder(action, true).to_s[0..4].should == 'https'
    end
  end

  describe '.get_data' do
    let(:api_url) { "#{GoogleSafeBrowsing.config.host}/downloads#{encoded_params}" }

    it 'executes a post to Google' do
      stub_request(:post, api_url).to_return(body: get_data_response)

      GoogleSafeBrowsing::HttpHelper.get_data

      WebMock.should have_requested(:post, api_url)
    end
  end

  describe 'private method' do
    let(:api_uri) { URI "#{GoogleSafeBrowsing.config.host}/downloads#{encoded_params}" }

    describe '.post_data' do
      it 'accepts a block to compose the request body' do
        stub_request(:post, api_uri.to_s).to_return(status: 200,
                                                    body: get_data_response,
                                                    headers: {})
        expected_body = 'hello'
        GoogleSafeBrowsing::HttpHelper.post_data(api_uri) { expected_body }

        WebMock.should have_requested(:post, api_uri.to_s).
          with(body: expected_body)
      end
    end
  end

  def get_data_response
    File.read(File.join(File.dirname(__FILE__),
                        '..',
                        'responses',
                        'get_data_body.txt'))
  end
end
