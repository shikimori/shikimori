class AddTextToPolls < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :text, :text, null: false, default: ''
  end
end
