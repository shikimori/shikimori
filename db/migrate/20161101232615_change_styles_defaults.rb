class ChangeStylesDefaults < ActiveRecord::Migration[5.2]
  def up
    change_column_default :styles, :css, default: ''
    change_column_default :styles, :name, default: ''
  end

  def down
    change_column_default :styles, :css, default: nil
    change_column_default :styles, :name, default: nil
  end
end
