class RemoveDescriptionDescriptionMalFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :description
    remove_column :people, :description_mal
  end
end
