require 'rails/generators'
require 'rails/generators/migration'

module GoogleSafeBrowsing
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    desc "Creates Migrations for Shavar Hashes and Full Hashes. Creates initializer file for API Key."

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    def self.next_migration_number(path)
      if ActiveRecord::Base.timestamped_migrations
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      else
        "%.3d" % (current_migration_number(dirname) + 1)
      end
    end

    def create_migration_files
      migration_template 'create_google_safe_browsing_tables.rb',
                         'db/migrate/create_google_safe_browsing_tables.rb'
    end
  end
end
