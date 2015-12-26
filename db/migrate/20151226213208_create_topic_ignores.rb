class CreateTopicIgnores < ActiveRecord::Migration
  def change
    create_table :topic_ignores do |t|
      t.references :user, index: true, null: false
      t.references :topic, index: true, null: false

      t.timestamps null: false
    end

    add_index :topic_ignores, [:user_id, :topic_id], unique: true
  end
end
