class RemoveNullableJapaneseInStudios < ActiveRecord::Migration
  def up
    change_column :studios, :japanese, :string, null: true
  end

  def down
    change_column :studios, :japanese, :string, null: false
  end
end
