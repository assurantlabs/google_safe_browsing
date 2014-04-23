module GoogleSafeBrowsing
  class SubShavar < ActiveRecord::Base
    include Shavar
    extend Shavar::ClassMethods

    self.table_name = 'gsb_sub_shavars'
  end
end
