class DropGivenFamiliNameFromPeople < ActiveRecord::Migration[5.2]
  def change
    remove_column :people, :given_name, :string
    remove_column :people, :family_name, :string
  end
end
