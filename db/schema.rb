# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_07_11_215741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "redirects", force: :cascade do |t|
    t.string "from"
    t.string "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "static_docs_pages", force: :cascade do |t|
    t.string "title"
    t.string "path"
    t.string "namespace"
    t.text "body"
    t.string "extension"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["namespace"], name: "index_static_docs_pages_on_namespace"
    t.index ["path"], name: "index_static_docs_pages_on_path"
  end

end
