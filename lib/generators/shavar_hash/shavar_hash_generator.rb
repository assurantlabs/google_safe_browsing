require 'rails/generators/migration'

module GoogleSafeBrowsing
  module Generators
    class ShavarHashGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_model_file
        template 'shavar_hash.rb', 'app/models/shavar_hash.rb'
        migration_template 'create_shavar_hashes.rb', "db/migrate/create_shavar_hashes"
      end
    end
  end
end
