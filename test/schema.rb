ActiveRecord::Schema.define :version => 0 do

  create_table :ratings, :force => true do |t|
    t.integer  "rateable_id",   :null => false
    t.string   "rateable_type", :null => false
    t.integer  "rater_id",     :null => false
    t.string   "rater_type",   :null => false
    t.integer "score", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table :users, :force => true do |t|
    t.column :name, :string
  end

  create_table :bands, :force => true do |t|
    t.column :name, :string
  end

end
