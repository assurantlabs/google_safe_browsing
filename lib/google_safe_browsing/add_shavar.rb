module GoogleSafeBrowsing
  class AddShavar < ActiveRecord::Base
    include Shavar

    self.table_name = 'gsb_add_shavars'
  end
end
