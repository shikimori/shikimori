module UsersHelper
  class << self
    def localized_name entry, user
      russian_option = entry.is_a?(Genre) ? :russian_genres? : :russian_names
      allowed_russian = entry.respond_to?(:russian) && entry.russian.present?

      if allowed_russian && russian_names?(russian_option, user)
        entry.russian
      else
        entry.name
      end
    end

    def russian_names? russian_option, user
      I18n.russian? && (!user || user.preferences.try(russian_option))
    end
  end

  # название с учётом настроек отображения русского языка
  # DEPRECATED
  # TODO: заменить на localization_span
  def localized_name entry
    UsersHelper.localized_name entry, current_user
  end

  def localization_span entry, is_search_russian: nil
    key = entry.is_a?(Genre) ? 'genre' : 'name'

    if is_search_russian.nil?
      if entry.try(:russian).present?
        "<span class='#{key}-en'>#{h entry.name}</span>"\
          "<span class='#{key}-ru'>#{h entry.russian}</span>".html_safe
      else
        entry.name
      end
    elsif is_search_russian && entry.try(:russian).present?
      entry.russian
    else
      entry.name
    end
  end

  def localization_field
    russian_names? ? :russian : :name
  end

  def russian_names? russian_option = :russian_names
    UsersHelper.russian_names? russian_option, current_user
  end
end
