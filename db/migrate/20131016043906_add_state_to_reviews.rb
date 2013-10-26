class AddStateToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :state, :string, default: :pending
  end
end
