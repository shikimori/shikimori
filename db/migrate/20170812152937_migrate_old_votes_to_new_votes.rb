class MigrateOldVotesToNewVotes < ActiveRecord::Migration[5.1]
  def up
    ActiveRecord::Base.connection.execute(
      <<-SQL
        insert into
          votes (
            votable_type,
            votable_id,
            voter_type,
            voter_id,
            vote_flag,
            created_at,
            updated_at
          )
          select
            voteable_type as votable_type,
            voteable_id as votable_id,
            'User' as voter_type,
            user_id as voter_id,
            voting as vote_flag,
            created_at,
            created_at as updated_at
          from
            votes_old
      SQL
    )
  end

  def down
    ActiveRecord::Base.connection.execute(
      <<-SQL
        delete from votes
      SQL
    )
  end
end
