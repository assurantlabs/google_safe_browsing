require 'spec_helper'

Struct.new('StubResponse', :body)

describe GoogleSafeBrowsing::HttpHelper do
  let(:encoded_params) { "?client=api&apikey=#{GoogleSafeBrowsing.config.api_key}&appver=#{GoogleSafeBrowsing.config.app_ver}&pver=2.2" }
  let(:rekey_url) { "https://sb-ssl.google.com/safebrowsing/newkey#{encoded_params}" }
  before(:each) do
    set_keys
    stub_request(:get, rekey_url).to_return(body: get_keys_response)
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
      stub_request(:post, api_url).to_return(body: get_data_response)

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
          Struct::StubResponse.new(get_data_response)
        end

        WebMock.should have_requested(:get, rekey_url)
      end

      it 'attempts to rekey if the response indicates such' do
        GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) { rekey_then_valid }

        WebMock.should have_requested(:get, rekey_url)
      end

      it 'returns the response if the mac is valid' do
        expected_response = Struct::StubResponse.new(get_data_response)
        GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) { expected_response }.
          should == expected_response
      end

      it 'throws a InvalidMACValidation error when the mac is invalid' do
        expect do
          GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) do
            Struct::StubResponse.new(invalid_mac_response)
          end
        end.to raise_error InvalidMACValidation
      end

      context 'when the response is no content' do
        it 'is nil' do
          expect(
            GoogleSafeBrowsing::HttpHelper.with_keys(api_uri) do
              Struct::StubResponse.new(nil)
            end
          ).to be_nil
        end
      end
    end

    describe '.valid_mac?' do
      let(:expected_mac) { 'f-N8Rs5xq1tPXPdkvY-j7zeL1do=' }
      let(:correct_data) { 'onetwothree' }
      let(:incorrect_data) { 'this will not come out correct' }

      it 'invalidates when no MAC is given' do
        expect(GoogleSafeBrowsing::HttpHelper.valid_mac?(correct_data, '')).to \
          be_false
      end

      it 'invalidates when no data is given' do
        expect(GoogleSafeBrowsing::HttpHelper.valid_mac?('', expected_mac)).to \
          be_false
      end

      it 'invalidates when no data or MAC is given' do
        expect(GoogleSafeBrowsing::HttpHelper.valid_mac?('', '')).to be_false
      end

      it 'validates a correct MAC based on the client key' do
        expect(
          GoogleSafeBrowsing::HttpHelper.valid_mac?(correct_data, expected_mac)
        ).to be_true
      end

      it 'invalidates when the client key does not match the computed MAC' do
        GoogleSafeBrowsing.config.client_key = 'this is not the key'

        GoogleSafeBrowsing::HttpHelper.valid_mac?(correct_data, expected_mac).
          should be_false
      end

      it 'invalidates when the provided MAC does not match the computed MAC' do
        GoogleSafeBrowsing::HttpHelper.valid_mac?(incorrect_data, expected_mac).
          should be_false
      end
    end

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

    describe '.please_rekey?' do
      it 'returns true when the response includes the please rekey directive' do
        GoogleSafeBrowsing::HttpHelper.please_rekey?(please_rekey_response).
          should be_true
      end

      it 'returns false when no rekey directive appears' do
        GoogleSafeBrowsing::HttpHelper.please_rekey?(get_data_response).should be_false
      end
    end

    describe '.switch_to_https' do
      it 'replaces the http protocol with https' do
        GoogleSafeBrowsing::HttpHelper.switch_to_https('http://mobiledefense.com').should == 'https://mobiledefense.com'
      end
    end
  end

  def get_data_response
    File.read(File.join(File.dirname(__FILE__),
                        '..',
                        'responses',
                        'get_data_body.txt'))
  end

  def get_keys_response
    "clientkey:16:#{client_key}\nwrappedkey:24:MTqdJvrixHRGAyfebvaQWYda"
  end

  def invalid_mac_response
    "m:234wewerf===\nu:mobiledefense.com"
  end

  def please_rekey_response
    "e:pleaserekey\nm:other_data_to_ignore"
  end

  def client_key
    'Y2xpZW50IGtleQ=='
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

    Struct::StubResponse.new(response)
  end

  def set_keys
    GoogleSafeBrowsing.config.client_key = GoogleSafeBrowsing::KeyHelper.web_safe_base64_decode(client_key)
    GoogleSafeBrowsing.config.wrapped_key = '2344sadrw34tsethesthgserg5w4hgsetdxgfhbndtsrf'
    GoogleSafeBrowsing.config.mac_required = true
  end
end
