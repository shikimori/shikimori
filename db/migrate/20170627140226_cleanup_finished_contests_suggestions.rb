class CleanupFinishedContestsSuggestions < ActiveRecord::Migration[5.0]
  def up
    Contest.where(state: %i[started finished]).each do |contest|
      contest.suggestions.delete_all
    end
  end
end
