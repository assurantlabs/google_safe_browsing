module GoogleSafeBrowsing
  class FullHash < ActiveRecord::Base
    self.table_name = 'gsb_full_hashes'

    def self.delete_subbed
      sub_join = <<-SQL
        INNER JOIN gsb_sub_shavars
        ON gsb_sub_shavars.add_chunk_number = gsb_full_hashes.add_chunk_number
        AND gsb_sub_shavars.list = gsb_full_hashes.list
      SQL

      hash_ids = joins(sub_join).pluck("distinct #{self.table_name}.id")
      where(id: hash_ids).delete_all
    end
  end
end
