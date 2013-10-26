class AlterGenerated < ActiveRecord::Migration
  def up
    change_column :entries, :generated, :boolean, default: false
  end
end
