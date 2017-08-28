class ForceCachingForExistingVotesForContestMatches < ActiveRecord::Migration[5.1]
  def up
    ContestMatch
      .joins("left join #{ContestUserVote.table_name} cuv on cuv.contest_match_id=#{ContestMatch.table_name}.id")
        .group("#{ContestMatch.table_name}.id")
        .select("#{ContestMatch.table_name}.*,
                sum(case when cuv.item_id=0 then 1 else 0 end) as refrained_votes_old,
                sum(case when cuv.item_id=left_id then 1 else 0 end) as left_votes_old,
                sum(case when cuv.item_id=right_id then 1 else 0 end) as right_votes_old")
      .find_each do |contest_match|
        contest_match.update_columns(
          cached_votes_up: contest_match.left_votes_old,
          cached_votes_down: contest_match.right_votes_old,
          cached_votes_total: contest_match.left_votes_old +
            contest_match.right_votes_old +
            contest_match.refrained_votes_old
        )
    end
  end
end
