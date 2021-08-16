class AddWidthFieldToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :width, :string, null: false, default: 'limited'
  end
end
