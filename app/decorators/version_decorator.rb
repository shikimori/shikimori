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
        "[#{genres value, false}]"

      when 'genre_v2_ids'
        "[#{genres value, true}]"

      else
        value
    end
  end

  def decorated_cache_key
    is_can_manage = h.can? :manage, object

    [
      object,
      is_can_manage && may_accept?,
      is_can_manage && may_reject?,
      is_can_manage && may_accept_taken?,
      is_can_manage && may_take_accepted?,
      h.can?(:destroy, object) && may_to_deleted?,
      h.current_user&.id == user_id,
      display_uncensored_for_staff?
    ]
  end

  def genres ids, is_v2
    "#{item_type}Genres#{'V2' if is_v2}Repository".constantize.instance
      .find(ids)
      .sort_by { |genre| ids.index genre.id }
      .map { |genre| h.localized_name genre }
      .join(', ')
  end

  def display_uncensored_for_staff?
    h.current_user&.staff? && object.is_a?(Versions::RoleVersion) &&
      (object.item.censored_avatar? || object.item.censored_nickname?)
  end
end
