class AddRussianToPeople < ActiveRecord::Migration
  def change
    add_column :people, :russian, :string
  end
end
