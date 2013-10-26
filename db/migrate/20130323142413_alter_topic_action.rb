class AlterTopicAction < ActiveRecord::Migration
  def up
    change_column :entries, :action, :string, default: '', null: false
  end
end
