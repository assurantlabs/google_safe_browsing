class CreateChunks < ActiveRecord::Migration
  def self.up
    create_table :chunks do |t|
      t.string :chunk_type, :null => false
      t.integer :number, :null => false
      t.string :list, :null => false
    end

    add_index :chunks, :list
  end

  def self.down
    drop_table :chunks
  end
end
