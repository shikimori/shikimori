class FixStyles < ActiveRecord::Migration
  def change
    change_column_default :styles, :name, ''
    change_column_default :styles, :css, ''
  end
end
