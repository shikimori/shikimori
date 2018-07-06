class FillRolesInPersonRoles < ActiveRecord::Migration[5.1]
  def up
    PersonRole.connection.execute(
      <<-SQL
        update person_roles set roles=string_to_array(role, ', ');
      SQL
    )
  end

  def down
    PersonRole.connection.execute(
      <<-SQL
        update person_roles set role=array_to_string(roles, ', ');
      SQL
    )
  end
end
