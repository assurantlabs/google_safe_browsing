require 'generator_spec/test_case'

require 'generators/google_safe_browsing/install_generator'

describe GoogleSafeBrowsing::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)

  before do
    prepare_destination
    run_generator
  end

  specify do
    destination_root.should have_structure {
      directory "db" do
        directory "migrate" do
          migration "create_shavar_hashes" do
            contains "class CreateShavarHashes"
          end
          migration "create_chunks" do
            contains "class CreateChunks"
          end
        end

      end
    }
  end
end

