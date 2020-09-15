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

  ASSIGN_FIELDS = %i[
    description_en
    description_ru
    english
    genre_ids
    imageboard_tag
    license_name_ru
    licensor
    name
    japanese
    popularity
    publisher_ids
    ranked
    rating
    russian
    score
    source
    stuio_ids

    birthday
    website
  ]

  MERGE_FIELDS = %i[
    synonyms
    coub_tags
    fansubbers
    fandubbers
  ]

  def call
    @other.class.transaction do
      assign_fields
      merge_fields
      @other.save! if @other.changed?

      RELATIONS.each do |relation|
        send :"merge_#{relation}"
      end

      DbEntry::Destroy.call @entry.class.find(@entry.id)
    end
  end

private

  def assign_fields
    ASSIGN_FIELDS.each do |field|
      next unless @entry.respond_to?(field) && @other.respond_to?(field)
      next unless @other.send(field).blank? && @entry.send(field).present?

      @other.assign_attributes field => @entry.send(field)
    end
  end

  def merge_fields
    MERGE_FIELDS.each do |field|
      next unless @entry.respond_to?(field) && @other.respond_to?(field)

      @other.assign_attributes field => (@other.send(field) + @entry.send(field)).sort.uniq
    end
  end

  def merge_user_rates
    return unless @entry.respond_to? :rates

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
    return unless @entry.respond_to? :reviews

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
    return unless @entry.respond_to? :cosplay_gallery_links

    @entry.cosplay_gallery_links.each { |v| v.update linked: @other }
  end

  def merge_recommendation_ignores
    return unless @entry.respond_to? :recommendation_ignores

    @entry.recommendation_ignores.each { |v| v.update target: @other }
  end

  def merge_contest_links # rubocop:disable AbcSize
    @entry.contest_links.each { |v| v.update! linked: @other }
    @entry.contest_winners.each { |v| v.update! item: @other }

    ContestMatch
      .where(left: @entry)
      .or(ContestMatch.where(right: @entry))
      .each do |contest_match|
        contest_match.left_id = @other.id if contest_match.left_id == @entry.id
        contest_match.right_id = @other.id if contest_match.right_id == @entry.id
        contest_match.winner_id = @other.id if contest_match.winner_id == @entry.id
        contest_match.save!
      end
  end

  def merge_anime_links
    return unless @entry.respond_to?(:anime_links) && @other.respond_to?(:anime_links)

    @entry.anime_links.each { |v| v.update anime: @other }
  end

  def merge_favourites
    @entry.favourites.each do |v|
      v.update linked_id: @other.id, linked_type: @other.class.name
    end
  end

  def merge_external_links
    return unless @entry.respond_to? :external_links

    @entry.external_links.each { |v| v.update entry: @other }
  end
end
