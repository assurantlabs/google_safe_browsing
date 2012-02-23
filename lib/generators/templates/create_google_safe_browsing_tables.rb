class CreateGoogleSafeBrowsingTables < ActiveRecord::Migration
  def self.up
    create_table :chunks do |t|
      t.string :action, :null => false
      t.integer :number, :null => false
      t.string :list, :null => false
      t.timestamps
    end

    add_index :chunks, [:list, :number, :action], :unique => true

    create_table :shavar_hashes do |t|
      t.string :prefix
      t.string :host_key, :null => false
      t.integer :chunk_number, :null => false
      t.string :list, :null => false
      t.string :action, :null => false
      t.timestamps
    end

    add_index :shavar_hashes, :host_key
    add_index :shavar_hashes, [:host_key, :prefix ]
  end

  def self.down
    drop_table :chunks
    drop_table :shavar_hashes
  end
end
