class ChangeRussianInCharactersToString < ActiveRecord::Migration
  def change
    change_column :characters, :russian, :string
  end
end
