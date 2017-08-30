class FillCachedUniqVotersForFinishedContests < ActiveRecord::Migration[5.1]
  def up
    Contest.where(state: :finished).each do |contest|
      contest.update_columns(
        cached_uniq_voters_count: contest
          .rounds
          .joins(matches: :contest_user_votes)
          .select('count(distinct(contest_user_votes.user_id)) as uniq_voters')
          .except(:order)
            .to_a
            .first
            .uniq_voters
      )
    end
  end
end
