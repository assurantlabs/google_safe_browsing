module GoogleSafeBrowsing
  class AddShavar < ActiveRecord::Base
    include Shavar
    extend Shavar::ClassMethods

    self.table_name = 'gsb_add_shavars'
  end
end
