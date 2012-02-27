class CreateGoogleSafeBrowsingTables < ActiveRecord::Migration
  def self.up

    create_table :gsb_full_hashes do |t|
      t.string  :full_hash
      t.integer :add_chunk_number
      t.string  :list
    end
    add_index :gsb_full_hashes, :full_hash

    create_table :gsb_add_shavars do |t|
      t.string :prefix
      t.string :host_key
      t.integer :chunk_number, :null => false
      t.string :list, :null => false
    end
    add_index :gsb_add_shavars, :host_key
    add_index :gsb_add_shavars, [:host_key, :prefix ]

    create_table :gsb_sub_shavars do |t|
      t.string :prefix
      t.string :host_key
      t.integer :add_chunk_number
      t.integer :chunk_number, :null => false
      t.string :list, :null => false
    end
    add_index :gsb_sub_shavars, :host_key
    add_index :gsb_sub_shavars, [:host_key, :prefix ]

  end

  def self.down
    drop_table :gsb_add_shavars
    drop_table :gsb_sub_shavars
    drop_table :gsb_full_hashes
  end
end
