class DbEntry::MergeIntoOther # rubocop:disable ClassLength
  method_object %i[entry! other!]

  RELATIONS = %i[
    user_rates
    topics
    comments
    reviews
    collection_links
    versions
    club_links
    cosplay_gallery_links
    recommendation_ignores
    contest_links
    anime_links
    favourites
    external_links
  ]

  FIELDS = %i[
    description_en
    description_ru
    english
    genre_ids
    imageboard_tag
    license_name_ru
    licensor
    name
    popularity
    publisher_ids
    ranked
    rating
    russian
    score
    source
    stuio_ids
    synonyms
  ]

  def call
    @other.class.transaction do
      merge_fields

      RELATIONS.each do |relation|
        send :"merge_#{relation}"
      end

      @entry.class.find(@entry.id).destroy!
    end
  end

private

  def merge_fields
    FIELDS.each do |field|
      next unless @entry.respond_to?(field) && @other.respond_to?(field)
      next unless @other.send(field).blank? && @entry.send(field).present?

      @other.assign_attributes field => @entry.send(field)
    end

    @other.save! if @other.changed?
  end

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
    rescue ActiveRecord::RecordInvalid
    end
  end

  def merge_topics
    @entry.all_topics
      .where(generated: false)
      .each { |v| v.update linked: @other }
  end

  def merge_comments # rubocop:disable MethodLength
    Shikimori::DOMAIN_LOCALES.each do |locale|
      @entry_topic = @entry.maybe_topic(locale)
      next if @entry_topic.comments_count.zero?

      @other_topic = @other.maybe_topic(locale)

      unless @other_topic.persisted?
        @other_topic = @other.generate_topics(locale).first
      end

      @entry_topic
        .comments
        .includes(:commentable)
        .find_each do |comment|
          comment.update commentable: @other_topic
          comment.send :increment_comments
        end

      if @entry_topic.commented_at && @entry_topic.commented_at < @other_topic.commented_at
        @entry_topic.update! commented_at: @other_topic.commented_at
      end
    end
  end

  def merge_reviews
    @entry.reviews.each { |v| v.update target: @other }
  end

  def merge_collection_links
    @entry.collection_links.each { |v| v.update linked: @other }
  end

  def merge_versions
    @entry.versions.each { |v| v.update item: @other }
  end

  def merge_club_links
    @entry.club_links.each { |v| v.update linked: @other }
  end

  def merge_cosplay_gallery_links
    @entry.cosplay_gallery_links.each { |v| v.update linked: @other }
  end

  def merge_recommendation_ignores
    @entry.recommendation_ignores.each { |v| v.update target: @other }
  end

  def merge_contest_links
    @entry.contest_links.each { |v| v.update linked: @other }
    @entry.contest_winners.each { |v| v.update item: @other }
  end

  def merge_anime_links
    return unless @entry.respond_to?(:anime_links) && @other.respond_to?(:anime_links)

    @entry.anime_links.each { |v| v.update anime: @other }
  end

  def merge_favourites
    @entry.favourites.each { |v| v.update linked: @other }
  end

  def merge_external_links
    @entry.external_links.each { |v| v.update entry: @other }
  end
end
