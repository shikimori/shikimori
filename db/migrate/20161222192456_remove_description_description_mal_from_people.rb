class RemoveDescriptionDescriptionMalFromPeople < ActiveRecord::Migration[5.2]
  def change
    remove_column :people, :description
    remove_column :people, :description_mal
  end
end
