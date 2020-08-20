class FixStyles < ActiveRecord::Migration[5.2]
  def change
    change_column_default :styles, :name, ''
    change_column_default :styles, :css, ''
  end
end
