require 'spec_helper'
require 'google_safe_browsing/binary_helper'

describe GoogleSafeBrowsing::BinaryHelper do
  describe 'read_bytes_as_hex' do
    it 'should read bytes from byter iterator as hexidecimal' do
      iter = 'abcd'.bytes
      count = 4
      GoogleSafeBrowsing::BinaryHelper.read_bytes_as_hex(iter, count).should== '61626364'
    end
  end
  describe 'four_as_hex' do
    it 'should take four bytes and unpack them into hex' do
      GoogleSafeBrowsing::BinaryHelper::four_as_hex('abcd').should== '61626364'
    end
  end

  describe 'unpack_host_key' do
    it 'should take four bytes and return them as a network order integer' do
      GoogleSafeBrowsing::BinaryHelper::unpack_host_key('abcd').should== '61626364'
    end
  end

  describe 'read_bytes_from' do
    it 'should read bytes from the stream'
  end
end
