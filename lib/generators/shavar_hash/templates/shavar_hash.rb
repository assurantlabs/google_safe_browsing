class ShavarHash < ActiveRecord::Base
  validates_presence_of :prefix, :host_key, :chunk_number
end
