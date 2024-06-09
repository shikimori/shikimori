class ModerationPolicy
  prepend ActiveCacher.instance

  pattr_initialize :user, :moderation_filter

  instance_cache :critiques_count, :collections_count,
    :abuse_requests_total_count,
    :abuse_requests_bannable_count,
    :abuse_requests_not_bannable_count,
    :all_content_versions_count,
    :names_versions_count,
    :texts_versions_count,
    :content_versions_count,
    :fansub_versions_count,
    :videos_versions_count,
    :images_versions_count,
    :links_versions_count

  def critiques_count
    return 0 unless !@moderation_filter || @user&.critique_moderator?

    Critique.pending.size
  end

  def collections_count
    return 0 unless !@moderation_filter || @user&.collection_moderator?

    Collection.pending.published.size
  end

  def news_count
    return 0 unless !@moderation_filter || @user&.news_moderator?

    Topics::NewsTopic.pending.size
  end

  def articles_count
    return 0 unless !@moderation_filter || @user&.article_moderator?

    Article.pending.size
  end

  def abuse_requests_total_count
    abuse_requests_bannable_count + abuse_requests_not_bannable_count
  end

  def abuse_requests_bannable_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.pending.bannable.size
  end

  def abuse_requests_not_bannable_count
    return 0 unless !@moderation_filter || @user&.forum_moderator?

    AbuseRequest.pending.not_bannable.size
  end

  def all_content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    pending_versions_size :all_content
  end

  def names_versions_count
    return 0 unless !@moderation_filter || @user&.version_names_moderator?

    pending_versions_size :names
  end

  def texts_versions_count
    return 0 unless !@moderation_filter || @user&.version_texts_moderator?

    pending_versions_size :texts
  end

  def content_versions_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    pending_versions_size :content
  end

  def fansub_versions_count
    return 0 unless !@moderation_filter || @user&.version_fansub_moderator?

    pending_versions_size :fansub
  end

  def videos_versions_count
    return 0 unless !@moderation_filter || @user&.version_videos_moderator?

    pending_versions_size :videos
  end

  def images_versions_count
    return 0 unless !@moderation_filter || @user&.version_images_moderator?

    pending_versions_size :images
  end

  def links_versions_count
    return 0 unless !@moderation_filter || @user&.version_links_moderator?

    pending_versions_size :links
  end

  def unprocessed_censored_posters_count
    0 unless !@moderation_filter || h.can?(:censore, Poster)

    unprocessed_censored_klass_posters_count(Anime) +
      unprocessed_censored_klass_posters_count(Manga)
  end

  def mal_more_info_count
    return 0 unless !@moderation_filter || @user&.version_moderator?

    Anime.where("more_info like '%[MAL]'").count + Manga.where("more_info like '%[MAL]'").count
  end

private

  def pending_versions_size type
    Moderation::VersionsItemTypeQuery.fetch(type).pending.size
  end

  def unprocessed_censored_klass_posters_count klass
    Animes::CensoredPostersQuery
      .call(
        klass:,
        moderation_state: Types::Moderatable::State[:pending]
      )
      .count
  end
end
