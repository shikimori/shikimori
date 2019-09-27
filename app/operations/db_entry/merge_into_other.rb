class DbEntry::MergeIntoOther
  method_object %i[entry! other!]

  def call
    @other.class.transaction do
      merge_user_rates
      merge_topics
      merge_reviews
      merge_collection_links
      merge_versions
      merge_club_links
      merge_cosplay_gallery_links
      merge_recommendation_ignores

      @entry.class.find(@entry.id).destroy!
    end
  end

private

  def merge_user_rates
    @entry.rates.each do |user_rate|
      user_rate.update! target: @other

      UserRateLog
        .where(user_id: user_rate.user_id)
        .where(target: @entry)
        .update_all target_id: @other.id, target_type: @other.class.name

      UserHistory
        .where(user_id: user_rate.user_id)
        .where(target: @entry)
        .update_all target_id: @other.id, target_type: @other.class.name
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    end
  end

  def merge_topics
    @entry.all_topics.where(generated: false).each do |topic|
      topic.update! linked: @other
    end
  end

  def merge_reviews
    @entry.reviews.each do |review|
      review.update! target: @other
    end
  end

  def merge_collection_links
    @entry.collection_links.each do |collection_link|
      collection_link.update! linked: @other
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def merge_versions
    @entry.versions.each do |version|
      version.update! item: @other
    end
  end

  def merge_club_links
    @entry.club_links.each do |club_link|
      club_link.update! linked: @other
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def merge_cosplay_gallery_links
    @entry.cosplay_gallery_links.each do |cosplay_gallery_link|
      cosplay_gallery_link.update! linked: @other
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def merge_recommendation_ignores
    @entry.recommendation_ignores.each do |recommendation_ignore|
      recommendation_ignore.update! target: @other
    rescue ActiveRecord::RecordNotUnique
    end
  end
end
