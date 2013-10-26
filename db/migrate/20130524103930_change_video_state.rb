class ChangeVideoState < ActiveRecord::Migration
  def up
    change_column :videos, :state, :string, default: 'uploaded', null: false
  end

  def down
    change_column :videos, :state, :string
  end
end
