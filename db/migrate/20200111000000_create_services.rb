class CreateServices < ActiveRecord::Migration[5.1]
  def change
    create_table "services", force: :cascade do |t|
      t.string   "provider"
      t.string   "uid"
      t.integer  "user_id"
      t.string   "uname"
      t.string   "account_name"
      t.string   "uemail"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "services", ["user_id"], name: "index_services_on_user_id", using: :btree
  end
end
