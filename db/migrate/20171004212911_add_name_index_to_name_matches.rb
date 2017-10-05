class AddNameIndexToNameMatches < ActiveRecord::Migration[5.1]
  def change
    add_index :name_matches, :phrase
  end
end
