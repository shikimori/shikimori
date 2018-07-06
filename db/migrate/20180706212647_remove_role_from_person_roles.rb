class RemoveRoleFromPersonRoles < ActiveRecord::Migration[5.1]
  def change
    remove_column :person_roles, :role, :string, limit: 255
  end
end
