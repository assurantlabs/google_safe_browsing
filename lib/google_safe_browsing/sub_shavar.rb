module GoogleSafeBrowsing
  class SubShavar < ActiveRecord::Base
    include Shavar

    self.table_name = 'gsb_sub_shavars'
  end
end
