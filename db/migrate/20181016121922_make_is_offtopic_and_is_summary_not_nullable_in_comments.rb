class MakeIsOfftopicAndIsSummaryNotNullableInComments < ActiveRecord::Migration[5.2]
  def up
    Comment.where(is_offtopic: nil).update_all is_offtopic: false
    Comment.where(is_summary: nil).update_all is_summary: false

    change_column :comments, :is_offtopic, :boolean, default: false, null: false
    change_column :comments, :is_summary, :boolean, default: false, null: false
  end

  def down
    change_column :comments, :is_offtopic, :boolean, default: false, null: true
    change_column :comments, :is_summary, :boolean, default: false, null: true
  end
end
