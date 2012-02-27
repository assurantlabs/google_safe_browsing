require 'spec_helper'
require 'google_safe_browsing/api_v2.rb'

describe GoogleSafeBrowsing::APIv2 do
  describe 'update' do
  end

  #describe 'delay' do
  #  it 'should stop execution for specified number of seconds' do
  #    start_time = Time.now
  #    seconds_delay = 3
  #    GoogleSafeBrowsing::APIv2::delay(seconds_delay)
  #    Time.now.should >= start_time + seconds_delay
  #  end
  #end


  describe 'receive_data' do
    #look up how to mock http requests
  end

  describe 'add_chunk' do
  end

  describe 'sub_chunk' do
  end

  describe 'get_lists' do
  end

  describe 'get_data' do
  end


  describe 'url_builder' do
  end

  describe 'encode_www_form' do
    it 'should convert a hash into a url params serialization' do
      expected = "?keytwo=val2&key=val"
      GoogleSafeBrowsing::APIv2::encode_www_form({ :key => 'val', :keytwo => 'val2' }).should== expected
    end
  end

end
