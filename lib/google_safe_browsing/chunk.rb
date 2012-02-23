module GoogleSafeBrowsing
  class Chunk < ActiveRecord::Base
    validates_presence_of :action, :list, :number
  end
end
