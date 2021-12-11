class Users::ActivityStats
  include ShallowAttributes

  attribute :comments_count, Integer
  attribute :topics_count, Integer
  attribute :reviews_count, Integer
  attribute :critiques_count, Integer
  attribute :collections_count, Integer
  attribute :articles_count, Integer
  attribute :versions_count, Integer
  attribute :video_uploads_count, Integer
  attribute :video_reports_count, Integer
  attribute :video_versions_count, Integer

  def social_activity?
    comments_count.positive? || reviews_count.positive? ||
      critiques_count.positive? || versions_count.positive? ||
      video_uploads_count.positive? || video_changes_count.positive?
  end

  def video_changes_count
    video_reports_count + video_versions_count
  end
end
