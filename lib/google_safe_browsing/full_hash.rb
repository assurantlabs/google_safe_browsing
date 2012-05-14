module GoogleSafeBrowsing
  class FullHash < ActiveRecord::Base
    self.table_name = 'gsb_full_hashes'
  end
end
