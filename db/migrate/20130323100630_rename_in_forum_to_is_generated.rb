class RenameInForumToIsGenerated < ActiveRecord::Migration
  def up
    rename_column :entries, :in_forum, :generated
  end

  def down
    rename_column :entries, :generated, :in_forum
  end
end
