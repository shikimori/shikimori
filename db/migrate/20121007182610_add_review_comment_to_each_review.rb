
class AddReviewCommentToEachReview < ActiveRecord::Migration
  def self.up
    Entry.record_timestamps = false
    ReviewComment.record_timestamps = false

    Review.all.each do |review|
      review.create_review_comment unless review.comments.present?
    end

    Entry.record_timestamps = true
    ReviewComment.record_timestamps = true
  end

  def self.down
  end
end
