module UsersHelper
  class << self
    def localized_name entry, current_user
      russian_option = entry.kind_of?(Genre) ? :russian_genres? : :russian_names
      allowed_russian = entry.respond_to?(:russian) && entry.russian.present?

      if allowed_russian && russian_names?(russian_option, current_user)
        entry.russian
      else
        entry.name
      end
    end

    def russian_names? russian_option, current_user
      I18n.russian? &&
        (!current_user || current_user.preferences.try(russian_option))
    end
  end

  # название с учётом настроек отображения русского языка
  def localized_name entry
    UsersHelper.localized_name entry, current_user
  end

  def russian_names? russian_option = :russian_names
    UsersHelper.russian_names? russian_option, current_user
  end

  def page_background
    if user_signed_in? && current_user.preferences.page_background.to_f > 0
      color = 255 - current_user.preferences.page_background.to_f.ceil
      "background-color: rgb(#{color},#{color},#{color});"
    end
  end

  def page_border
    user = @user || current_user

    if user && user.persisted? && user.preferences.page_border
      :bordered
    end
  end
end
