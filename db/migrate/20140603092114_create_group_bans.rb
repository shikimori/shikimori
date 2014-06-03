class CreateGroupBans < ActiveRecord::Migration
  def change
    create_table :group_bans do |t|
      t.references :group, index: true, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end

    add_index :group_bans, [:group_id, :user_id], unique: true
  end
end
