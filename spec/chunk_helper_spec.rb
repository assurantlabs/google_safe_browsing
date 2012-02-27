require 'spec_helper'
require 'google_safe_browsing/chunk_helper'

describe GoogleSafeBrowsing::ChunkHelper do
  describe 'building chunk lists' do
    describe 'without and chunks' do
      it 'should build a single chunk list if given a list' do
        GoogleSafeBrowsing::ChunkHelper.build_chunk_list('googpub-phish-shavar').should== 
          "googpub-phish-shavar;\n"
      end

      it 'should build the current defaults if no lists given' do
        GoogleSafeBrowsing::ChunkHelper.build_chunk_list.should== 
          GoogleSafeBrowsing.config.current_lists.map{|l| "#{l};\n"}.join
      end
    end

    describe 'with data' do
      it 'should read the chunk numbers and produce the correct chunklist format'
    end
  end

  describe 'squishing number lists' do
    it 'should take an array and return the continuous blocks' do
      @number_array = [1,2,3,4,5,6,7,8,9,10,15,16,17,18,21,24]
      @expected = "1-10,15-18,21,24"
      GoogleSafeBrowsing::ChunkHelper.squish_number_list(@number_array).should== @expected
    end
  end

  describe 'converting a chunklist to a SQL clause' do
    it 'should take a chunklist formatted string and return the sql to return those records' do
      @chunklist = "1-10,15-18,21,24"
      @expected  = "chunk_number between 1 and 10 or chunk_number between 15 and 18 or chunk_number = 21 or chunk_number = 24"
      GoogleSafeBrowsing::ChunkHelper.chunklist_to_sql(@chunklist).should== @expected
    end
  end
end

