require 'spec_helper'

describe GoogleSafeBrowsing::BinaryHelper do
  describe 'read_bytes_as_hex' do
    it 'should read bytes from byter iterator as hexidecimal' do
      iter = 'abcd'.bytes
      count = 4
      expect(GoogleSafeBrowsing::BinaryHelper.read_bytes_as_hex(iter, count)).to eq '61626364'
    end
  end
  describe 'four_as_hex' do
    it 'should take four bytes and unpack them into hex' do
      expect(GoogleSafeBrowsing::BinaryHelper::four_as_hex('abcd')).to eq '61626364'
    end
  end

  describe 'unpack_host_key' do
    it 'should take four bytes and return them as a network order integer' do
      expect(GoogleSafeBrowsing::BinaryHelper::unpack_host_key('abcd')).to eq '61626364'
    end
  end

  describe 'read_bytes_from' do
    it 'should read bytes from the stream' do
      expected = 'abcd'
      iter = expected.bytes
      expect(
        GoogleSafeBrowsing::BinaryHelper.read_bytes_from(iter,
                                                         expected.length)
      ).to eq expected
    end
  end
end
