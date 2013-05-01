require 'spec_helper'
require 'ostruct'

describe GoogleSafeBrowsing::HttpHelper do
  let(:encoded_params) { "?client=api&apikey=#{GoogleSafeBrowsing.config.api_key}&appver=#{GoogleSafeBrowsing.config.app_ver}&pver=2.2" }
  let(:rekey_url) { "https://sb-ssl.google.com/safebrowsing/newkey#{encoded_params}" }
  before(:each) do
    set_keys
    stub_request(:get, rekey_url).to_return(get_keys_response)
  end

  describe '.uri_builder' do
    let(:action) { 'downloads' }
    before(:each) do
      GoogleSafeBrowsing.config.client_key = nil
      GoogleSafeBrowsing.config.wrapped_key = nil
    end

    it 'builds URIs from actions' do
      expected = URI("#{GoogleSafeBrowsing.config.host}/#{action}#{encoded_params}")
      GoogleSafeBrowsing::HttpHelper.uri_builder(action).should == expected
    end

    it 'builds https URIs from actions' do
      GoogleSafeBrowsing::HttpHelper.uri_builder(action, true).to_s[0..4].should == 'https'
    end

    it 'excludes the wrapped key when mac is not required' do
      GoogleSafeBrowsing.config.mac_required = false
      GoogleSafeBrowsing::HttpHelper.uri_builder(action).request_uri.should_not =~ /wrkey/
    end
  end

  describe '.get_data' do
    let(:api_url) { "#{GoogleSafeBrowsing.config.host}/downloads#{encoded_params}" }

    it 'executes a post to Google' do
      GoogleSafeBrowsing.config.mac_required = false
      stub_request(:post, api_url).to_return(get_data_response)

      GoogleSafeBrowsing::HttpHelper.get_data

      WebMock.should have_requested(:post, api_url)
    end

  end

  describe '.get_keys' do
    before(:each) do
      GoogleSafeBrowsing.config.client_key = nil
      GoogleSafeBrowsing.config.wrapped_key = nil
    end

    it 'sets the MAC keys' do
      GoogleSafeBrowsing::HttpHelper.get_keys

      GoogleSafeBrowsing.config.client_key.should_not be_nil
      GoogleSafeBrowsing.config.wrapped_key.should_not be_nil
    end
  end

  describe 'private method' do
    let(:api_uri) { URI "#{GoogleSafeBrowsing.config.host}/downloads#{encoded_params}" }

    describe '.with_keys' do
      it 'attempts to rekey if no keys are present' do
        GoogleSafeBrowsing.config.client_key = nil

        GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) do
          OpenStruct.new(get_data_response)
        end

        WebMock.should have_requested(:get, rekey_url)
      end

      it 'attempts to rekey if the response indicates such' do
        GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) { rekey_then_valid }

        WebMock.should have_requested(:get, rekey_url)
      end

      it 'returns the response if the mac is valid' do
        expected_response = OpenStruct.new(get_data_response)
        GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) { expected_response }.
          should == expected_response
      end

      it 'throws a InvalidMACValidation error when the mac is invalid' do

        -> {
          GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) do
            OpenStruct.new(invalid_mac_response)
          end
        }.should raise_error InvalidMACValidation
      end
    end

    describe '.valid_mac?' do
      it 'returns false when no respose is given' do
        GoogleSafeBrowsing::HttpHelper.valid_mac?('').should be_false
      end

      it 'validates a correct MAC based on the client key' do
        GoogleSafeBrowsing::HttpHelper.valid_mac?(get_data_response[:body]).should be_true
      end

      it 'returns false when the client key does not match the MAC' do
        GoogleSafeBrowsing.config.client_key = "this is not a key"

        GoogleSafeBrowsing::HttpHelper.valid_mac?(get_data_response[:body]).should be_false
      end
    end

    describe '.post_data' do
      it 'accepts a block to compose the request body' do
        stub_request(:post, api_uri.to_s).to_return(status: 200,
                                                    body: get_data_response[:body],
                                                    headers: {})
        expected_body = 'hello'
        GoogleSafeBrowsing::HttpHelper.post_data(api_uri) { expected_body }

        WebMock.should have_requested(:post, api_uri.to_s).
          with(body: expected_body)
      end
    end

    describe '.please_rekey?' do
      it 'returns true when the response includes the please rekey directive' do
        GoogleSafeBrowsing::HttpHelper.please_rekey?(please_rekey_response[:body]).
          should be_true
      end

      it 'returns false when no rekey directive appears' do
        GoogleSafeBrowsing::HttpHelper.please_rekey?(get_data_response[:body]).should be_false
      end
    end

    describe '.switch_to_https' do
      it 'replaces the http protocol with https' do
        GoogleSafeBrowsing::HttpHelper.switch_to_https('http://mobiledefense.com').should == 'https://mobiledefense.com'
      end
    end
  end

  def get_data_response
    { body: File.read("#{File.dirname(__FILE__)}/responses/get_data_body.txt") }
  end

  def get_keys_response
    { body: "clientkey:16:#{client_key}\nwrappedkey:24:MTqdJvrixHRGAyfebvaQWYda" }
  end

  def invalid_mac_response
    { body: "m:234wewerf===\nu:mobiledefense.com" }
  end

  def please_rekey_response
    { body: "e:pleaserekey\nm:other_data_to_ignore" }
  end

  def client_key
    "Y2xpZW50IGtleQ=="
  end

  $first_time ||= true
  def rekey_then_valid
    response = if $first_time
                 $first_time = false
                 please_rekey_response
               else
                 $first_time = true
                 get_data_response
               end

    OpenStruct.new(response)
  end

  def set_keys
    GoogleSafeBrowsing.config.client_key = GoogleSafeBrowsing::KeyHelper.web_safe_base64_decode(client_key)
    GoogleSafeBrowsing.config.wrapped_key = '2344sadrw34tsethesthgserg5w4hgsetdxgfhbndtsrf'
    GoogleSafeBrowsing.config.mac_required = true
  end
end
