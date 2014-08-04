class ContestsWorker
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  retry: true

  def perform
    ContestUserVote
      .joins(:match, :user)
      .where(contest_matches: { id: match_ids }, user_id: user_ids)
      .delete_all

    ContestMatch.where(id: match_ids).each(&:obtain_winner_id!)
    ContestMatch.where(id: match_ids).each do |match|
      ip_cleanup match
    end

    Contest.where(state: 'started').each(&:process!)
  end

private

  def match_ids
    @match_ids ||= Contest.where(state: 'started').map(&:rounds).flatten.map(&:matches).flatten.map(&:id)
  end

  def user_ids
    @user_ids ||= ContestUserVote.joins(:match, :user).merge(User.suspicious).where(contest_matches: { id: match_ids }).pluck(:user_id).uniq
  end

  def ip_cleanup match
    cleaned = match.votes.group(:ip).having('count(*) > 1').select('max(id) as id').each(&:delete)
    ip_cleanup match if cleaned.any?
  end
end
