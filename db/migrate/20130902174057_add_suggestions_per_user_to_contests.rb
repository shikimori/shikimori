class AddSuggestionsPerUserToContests < ActiveRecord::Migration
  def change
    add_column :contests, :suggestions_per_user, :integer
  end
end
