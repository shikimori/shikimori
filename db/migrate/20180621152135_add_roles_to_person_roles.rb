class AddRolesToPersonRoles < ActiveRecord::Migration[5.1]
  def up
    add_column :person_roles, :roles, :text,
      default: [],
      null: false,
      array: true
    add_index :person_roles, :roles, using: :gin
  end

  def down
    remove_column :person_roles, :roles
  end
end
