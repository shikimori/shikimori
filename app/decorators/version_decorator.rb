class VersionDecorator < BaseDecorator
  include HTMLDiff

  def user
    object.user || User.find(User::GUEST_ID)
  end

  def changed_fields
    if kind_of? Versions::VideoVersion
      [i18n_t("field_name.video_#{action}")]
    elsif kind_of? Versions::ScreenshotsVersion
      [i18n_t("field_name.screenshots_#{action}")]
    else
      item_diff.keys.map { |attribute| item_type.constantize.human_attribute_name attribute }
    end
  end

  def changes_tempalte field
    'versions/text_diff'
  end

  def item_template
    if item_type == AnimeVideo.name
      'versions/anime_video'

    else
      'versions/db_entry'
    end
  end

  def field_diff field
    diff old_value(field).to_s, new_value(field).to_s
  end

  def new_value field
    field_value field, item_diff[field.to_s][1]
  end

  def old_value field
    value = if pending? || rejected?
      object.current_value(field)
    else
      item_diff[field.to_s].first
    end

    field_value field, value
  end

  def field_value field, value
    if field.to_s == 'anime_video_author_id'
      AnimeVideoAuthor.find_by(id: value).try :name
    elsif field.to_s == 'genres'
      genres value
    else
      value
    end
  end

  def cache_key
    [
      object,
      (h.current_user.versions_moderator? if h.user_signed_in?),
      (h.current_user.video_moderator? if h.user_signed_in?),
      (h.current_user.admin? if h.user_signed_in?),
      (h.current_user.id == object.user_id if h.user_signed_in?),
      I18n.locale
    ]
  end

  def genres ids
    Genre
      .where(id: ids)
      .sort_by { |genre| ids.index genre.id }
      .map { |genre| h.localized_name genre }
      .join(', ')

  end
end
