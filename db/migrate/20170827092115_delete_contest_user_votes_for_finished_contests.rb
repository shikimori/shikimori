class DeleteContestUserVotesForFinishedContests < ActiveRecord::Migration[5.1]
  def change
    Contest
      .where(state: :finished)
      .includes(rounds: :matches)
      .each do |contest|
        contest.rounds.each do |round|
          round.matches.each do |match|
            match.contest_user_votes.delete_all
          end
        end
      end
  end
end
