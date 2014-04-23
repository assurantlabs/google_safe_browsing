module GoogleSafeBrowsing
  module Shavar
    module ClassMethods
      def delete_chunks_from_list(list, chunk_list)
        where(list: list, chunk_number: chunk_list.to_a).delete_all
      end
    end
  end
end
