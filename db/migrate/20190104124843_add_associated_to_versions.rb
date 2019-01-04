class AddAssociatedToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :associated_id, :integer
    add_column :versions, :associated_type, :string
    add_index :versions, %i[associated_id associated_type]
  end
end
