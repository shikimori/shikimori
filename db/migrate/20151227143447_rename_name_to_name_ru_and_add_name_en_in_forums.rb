class RenameNameToNameRuAndAddNameEnInForums < ActiveRecord::Migration
  def change
    rename_column :forums, :name, :name_ru
    add_column :forums, :name_en, :string
  end
end
