class DropGivenFamiliNameFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :given_name, :string
    remove_column :people, :family_name, :string
  end
end
