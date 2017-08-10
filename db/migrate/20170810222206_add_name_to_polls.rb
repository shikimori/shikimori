class AddNameToPolls < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :name, :string
  end
end
