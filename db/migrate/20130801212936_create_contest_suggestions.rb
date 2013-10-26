class CreateContestSuggestions < ActiveRecord::Migration
  def change
    create_table :contest_suggestions do |t|
      t.references :contest
      t.references :user
      t.references :item, polymorphic: true

      t.timestamps
    end
    add_index :contest_suggestions, :user_id
    add_index :contest_suggestions, :item_id
    add_index :contest_suggestions, :contest_id
  end
end
