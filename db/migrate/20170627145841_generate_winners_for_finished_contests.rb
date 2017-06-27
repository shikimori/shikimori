class GenerateWinnersForFinishedContests < ActiveRecord::Migration[5.0]
  def up
    Contest.order(:id).where(state: :finished).each do |contest|
      puts contest.id
      Contests::ObtainWinners.call contest
    end
  end
end
