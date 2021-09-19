class CreateReviewViewings < ActiveRecord::Migration[5.2]
  def change
    create_table :review_viewings do |t|
      t.references :user, null: false, index: false, foreign_key: true
      t.integer :viewed_id, null: false
      t.index [:user_id, :viewed_id], name: "index_review_viewings_on_user_id_and_viewed_id", unique: true
      t.index [:viewed_id], name: "index_review_viewings_on_viewed_id"
    end
  end
end
