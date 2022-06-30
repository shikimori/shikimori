class AddDateOfDeathToPeople < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :date_of_death, :date
  end
end
