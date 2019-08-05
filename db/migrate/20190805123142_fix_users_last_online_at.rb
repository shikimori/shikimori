class FixUsersLastOnlineAt < ActiveRecord::Migration[5.2]
  def change
    Style.connection.execute(
      <<~SQL
        update
          users
        set
          last_online_at = created_at
        where
          last_online_at is null
      SQL
    )
  end
end
