require 'generator_spec/test_case'

require 'generators/chunk/chunk_generator'

describe GoogleSafeBrowsing::Generators::ChunkGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path('../../tmp', __FILE__)

  before do
    prepare_destination
    run_generator
  end

  specify do
    destination_root.should have_structure {
      directory "app" do
        directory "models" do
          file "chunk.rb" do
            contains "class Chunk"
          end
        end
      end
      directory "db" do
        directory "migrate" do
          migration "create_chunks" do
            contains "class CreateChunks"
          end
        end
      end
    }
  end
end
