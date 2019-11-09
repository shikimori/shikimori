class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :name, null: false
      t.references :user, null: false, index: true
      t.text :text, null: false
      t.string :moderation_state, limit: 255, default: "pending"
      t.integer :approver_id
      t.text :tags, default: [], null: false, array: true
      t.string :locale, null: false

      t.timestamps
    end
  end
end
