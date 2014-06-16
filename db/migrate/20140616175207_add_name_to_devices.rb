class AddNameToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :name, :string
  end
end
