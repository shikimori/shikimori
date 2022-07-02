class AddDateOfDeathToPeople < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :deceased_on, :date
  end
end
