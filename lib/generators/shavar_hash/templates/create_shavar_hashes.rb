class CreateShaverHashes < ActiveRecord::Migration
  def self.up
    create_table :shavar_hashes do |t|
      t.string :prefix
      t.string :host_key, :null => false
      t.integer :chunk_number, :null => false
      t.string :list, :null => false
    end

    add_index :shavar_hashes, :host_key
    add_index :shavar_hashes, [:host_key, :prefix ]
  end

  def self.down
    drop_table :shavar_hashes
  end
end
