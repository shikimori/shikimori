class RemoveActsAsTaggableOn < ActiveRecord::Migration[5.2]
  def change
    drop_table "tags", id: :serial, force: :cascade do |t|
      t.string "name"
      t.integer "taggings_count", default: 0
      t.index ["name"], name: "index_tags_on_name", unique: true
    end

    drop_table "taggings", id: :serial, force: :cascade do |t|
      t.integer "tag_id"
      t.string "taggable_type"
      t.integer "taggable_id"
      t.string "tagger_type"
      t.integer "tagger_id"
      t.string "context", limit: 128
      t.datetime "created_at"
      t.index ["context"], name: "index_taggings_on_context"
      t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
      t.index ["tag_id"], name: "index_taggings_on_tag_id"
      t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
      t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
      t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
      t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
      t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
      t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    end
  end
end
