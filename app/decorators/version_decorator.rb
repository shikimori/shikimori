class VersionDecorator < BaseDecorator
  def user
    object.user || User.find(User::GUEST_ID)
  end

  def changed_fields
    if is_a? Versions::VideoVersion
      [i18n_t("field_name.video_#{action}")]

    elsif is_a? Versions::ScreenshotsVersion
      [i18n_t("field_name.screenshots_#{action}")]

    elsif is_a? Versions::PosterVersion
      [i18n_t("field_name.poster_#{action}")]

    elsif is_a? Versions::RoleVersion
      [i18n_t("field_name.role_#{action}")]

    else
      item_diff.keys.map { |attribute| item_type.constantize.human_attribute_name attribute }
    end
  end

  def new_value field
    field_value field, item_diff[field.to_s][1]
  end

  def old_value field
    value =
      if pending?
        object.current_value(field)
      else
        item_diff[field.to_s].first
      end

    field_value field, value
  end

  def field_value field, value
    case field.to_s
      when 'anime_video_author_id'
        AnimeVideoAuthor.find_by(id: value).try :name

      when 'genre_ids'
        "[#{genres value}]"

      else
        value
    end
  end

  def cache_key
    [
      object,
      h.can?(:manage, object),
      h.can?(:destroy, object),
      h.current_user&.id == object.user_id,
      I18n.locale
    ]
  end

  def genres ids
    "#{item_type}GenresRepository".constantize.instance
      .find(ids)
      .sort_by { |genre| ids.index genre.id }
      .map { |genre| h.localized_name genre }
      .join(', ')
  end
end
