class CleanupSelfVotes < ActiveRecord::Migration[5.2]
  def up
    [Collection, Review, Critique].each do |klass|
      klass
        .includes(:user)
        .find_each { |model| model.unvote_by model.user }
    end
  end
end
