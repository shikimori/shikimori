class AddDimenstionsForScreenshots < ActiveRecord::Migration[5.2]
  def change
    add_column :screenshots, :width, :integer
    add_column :screenshots, :height, :integer
  end
end
