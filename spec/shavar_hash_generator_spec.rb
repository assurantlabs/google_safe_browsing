require 'generator_spec/test_case'

require 'generators/shavar_hash/shavar_hash_generator'

describe GoogleSafeBrowsing::Generators::ShavarHashGenerator do
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
        end
      end
    }
  end
end

