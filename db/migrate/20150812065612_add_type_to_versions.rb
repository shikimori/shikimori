class AddTypeToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :type, :string
  end
end
