require 'rails/generators/migration'

class ChunkGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  def self.source_root
    File.expand_path("../templates", __FILE__)
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_model_file
    template 'chunk.rb', 'app/models/chunk.rb'
    migration_template 'create_chunks', "db/migrate/create_chunks"
  end
end
