class CleanupTaggings < ActiveRecord::Migration[5.2]
  def change
    drop_table "taggings", id: :serial, force: :cascade do |t|
      t.integer "tag_id"
      t.integer "taggable_id"
      t.string "taggable_type", limit: 255
      t.integer "tagger_id"
      t.string "tagger_type", limit: 255
      t.string "context", limit: 255
      t.datetime "created_at"
    end
  end
end
