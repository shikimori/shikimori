class UserImages::CleanupJob
  include Sidekiq::Worker
  sidekiq_options queue: :cleanup_jobs

  TEXT_FIELDS_MAPPING = {
    Club => :description,
    ClubPage => :text,
    Critique => :text,
    Article => :body,
    Review => :body,
    Poll => :text,
    User => :about,
    Collection => :text,
    Contest => :description_ru
  }

  def perform user_image_id
    used_image_ids =
      Rails.cache.fetch(:used_image_ids, expires_in: 5.minutes) { fetch_used_image_ids }
    return if used_image_ids.include? user_image_id.to_i

    UserImage.find_by(id: user_image_id)&.destroy
  end

private

  def fetch_used_image_ids
    TEXT_FIELDS_MAPPING
      .flat_map do |klass, field|
        klass
          .where("#{field} like '%image=%' or #{field} like '%poster=%'")
          .map { |v| v.send field }
          .compact
          .flat_map { |text| Comment::Cleanup.scan_user_image_ids text }
      end
      .uniq
  end
end
