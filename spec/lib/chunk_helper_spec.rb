require 'spec_helper'

describe GoogleSafeBrowsing::ChunkHelper do
  before do
    allow(GoogleSafeBrowsing.config).to receive(:have_keys?).and_return(false)
  end

  describe 'building chunk lists' do
    describe 'without and chunks' do
      it 'should build a single chunk list if given a list' do
        expect(GoogleSafeBrowsing::ChunkHelper.build_chunk_list('googpub-phish-shavar')).
          to eq "googpub-phish-shavar;\n"
      end

      it 'should build the current defaults if no lists given' do
        expect(GoogleSafeBrowsing::ChunkHelper.build_chunk_list).
              to eq GoogleSafeBrowsing.config
                                      .current_lists
                                      .map { |l| "#{l};\n" }
                                      .join
      end
    end
  end

  describe 'squishing number lists' do
    let(:number_array) do
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
       15, 16, 17, 18,
       21,
       24]
    end
    let(:expected) { '1-10,15-18,21,24' }

    it 'should take an array and return the continuous blocks' do
      expect(
        GoogleSafeBrowsing::ChunkHelper.squish_number_list(number_array)
      ).to eq expected
    end
  end
end
