class ProcessContestsJob
  def perform
    cleanup_bad_votes
    Contest.where(state: 'started').each(&:process!)
  end

  def cleanup_bad_votes
    matche_ids = Contest.where(state: 'started').map(&:rounds).flatten.map(&:matches).flatten.map(&:id)
    user_ids = ContestUserVote.joins(:match, :user).where("users.sign_in_count < 3").where(contest_matches: { id: matches_ids }).pluck(:user_id).uniq
    cleaned_user_ids = User.where(id: user_ids).select {|v| v.anime_rates.none? && v.comments.none? }.map(&:id)
    ContestUserVote.joins(:match, :user).where(contest_matches: { id: matches_ids }, user_id: cleaned_user_ids).destroy_all
    ContestMatch.where(id: matche_ids).each(&:obtain_winner_id!)
  end
end
