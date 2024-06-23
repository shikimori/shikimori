class AddIsCensoredVerifiedToPosters < ActiveRecord::Migration[7.0]
  def change
    add_column :posters, :is_censored_verified, :boolean, null: false, default: false
  end
end
