# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120227221350) do

  create_table "gsb_add_shavars", :force => true do |t|
    t.string  "prefix"
    t.string  "host_key"
    t.integer "chunk_number", :null => false
    t.string  "list",         :null => false
  end

  add_index "gsb_add_shavars", ["host_key", "prefix"], :name => "index_gsb_add_shavars_on_host_key_and_prefix"
  add_index "gsb_add_shavars", ["host_key"], :name => "index_gsb_add_shavars_on_host_key"

  create_table "gsb_full_hashes", :force => true do |t|
    t.string  "full_hash"
    t.integer "add_chunk_number"
    t.string  "list"
  end

  add_index "gsb_full_hashes", ["full_hash"], :name => "index_gsb_full_hashes_on_full_hash"

  create_table "gsb_sub_shavars", :force => true do |t|
    t.string  "prefix"
    t.string  "host_key"
    t.integer "add_chunk_number"
    t.integer "chunk_number",     :null => false
    t.string  "list",             :null => false
  end

  add_index "gsb_sub_shavars", ["host_key", "prefix"], :name => "index_gsb_sub_shavars_on_host_key_and_prefix"
  add_index "gsb_sub_shavars", ["host_key"], :name => "index_gsb_sub_shavars_on_host_key"

end
