class RenameBirthAtToBirthOnForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :birth_at, :birth_on
  end
end
