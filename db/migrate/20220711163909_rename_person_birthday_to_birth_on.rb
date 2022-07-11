class RenamePersonBirthdayToBirthOn < ActiveRecord::Migration[6.1]
  def change
    rename_column :people, :birthday, :birth_on
  end
end
