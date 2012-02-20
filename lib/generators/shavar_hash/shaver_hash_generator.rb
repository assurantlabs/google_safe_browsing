require 'rails/generators/migration'

class ShavarHashGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    File.expand_path("../templates", __FILE__)
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_model_file
    template 'shaver_hash.rb', 'app/models/shavar_hash.rb'
    migration_template 'create_shavar_hashes', "db/migrate/create_shavar_hashes"
  end
end
