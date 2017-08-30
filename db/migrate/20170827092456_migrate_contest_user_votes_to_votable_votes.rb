class MigrateContestUserVotesToVotableVotes < ActiveRecord::Migration[5.1]
  def up
    scope = ContestUserVote.where(
      contest_match_id: ContestMatch.where(state: :started)
    )
    batch_num = 0
    batch_size = 5000
    votes = []

    puts <<-TEXT.squish
      #{scope.count} total =
      #{(scope.count * 1.0 / batch_size).ceil} batches
    TEXT

    scope.includes(:match, :user).find_each do |vote|
      vote_flag = if vote.item_id == vote.match.left_id
        ContestMatch::VOTABLE.invert['left']
      elsif vote.item_id == vote.match.right_id
        ContestMatch::VOTABLE.invert['right']
      else
        ContestMatch::VOTABLE.invert['abstain']
      end

      votes.push ActsAsVotable::Vote.new(
        votable: vote.match,
        voter: vote.user,
        vote_flag: vote_flag
      )

      if votes.size > batch_size
        puts "import #{batch_size}. batch_num=#{batch_num}"

        ActsAsVotable::Vote.import votes

        votes = []
        batch_num += 1
      end
    end

    if votes.any?
      ActsAsVotable::Vote.import votes
      puts "import #{votes.size}. batch_num=#{batch_num}"
    end
  end
end
