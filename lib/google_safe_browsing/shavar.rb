module GoogleSafeBrowsing
  module Shavar
    def self.delete_chunks_from_list(list, chunk_list)
      self.class.where(list: list, chunk_number: chunk_list.to_a).delete_all
    end
  end
end
