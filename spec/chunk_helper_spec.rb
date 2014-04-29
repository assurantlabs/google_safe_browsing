require 'spec_helper'

describe GoogleSafeBrowsing::ChunkHelper do
  before do
    GoogleSafeBrowsing.config.stub(:have_keys?).and_return(false)
  end
  describe 'building chunk lists' do
    describe 'without and chunks' do
      it 'should build a single chunk list if given a list' do
        GoogleSafeBrowsing::ChunkHelper.build_chunk_list('googpub-phish-shavar').
          should eq "googpub-phish-shavar;\n"
      end

      it 'should build the current defaults if no lists given' do
        GoogleSafeBrowsing::ChunkHelper.build_chunk_list.
          should eq GoogleSafeBrowsing.config
                                      .current_lists
                                      .map{ |l| "#{l};\n" }
                                      .join
      end
    end
  end

  describe 'squishing number lists' do
    it 'should take an array and return the continuous blocks' do
      @number_array = [1,2,3,4,5,6,7,8,9,10,15,16,17,18,21,24]
      @expected = "1-10,15-18,21,24"
      GoogleSafeBrowsing::ChunkHelper.squish_number_list(@number_array).should== @expected
    end
  end
end
