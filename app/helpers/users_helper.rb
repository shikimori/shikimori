module UsersHelper
  class << self
    def localized_name entry, current_user
      if entry.class == Genre
        # жанры
        if !current_user || (current_user && current_user.preferences.try(:russian_genres?) && entry.russian.present?)
          entry.russian || entry.name
        else
          entry.name
        end

      else
        # аниме
        if current_user && current_user.preferences.try(:russian_names?) && entry.respond_to?(:russian) && entry.russian.present?
          entry.russian
        else
          entry.name
        end
      end
    end

    def localized_kind entry, current_user, short=false
      return '' unless entry.kind.present?

      if !current_user || (current_user && current_user.preferences.russian_genres?)
        I18n.t "#{entry.decorated? ? entry.object.class.name : entry.class.name}.#{short ? 'Short.' : ''}#{entry.kind}"
      else
        entry.kind
      end
    end
  end

  # название с учётом настроек отображения русского языка
  def localized_name entry
    UsersHelper.localized_name entry, current_user
  end

  # тип с учётом настроек отображения русского языка
  def localized_kind entry, short=false
    UsersHelper.localized_kind entry, current_user, short
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

  def body_background
    user = @user || current_user

    if user && user.persisted? && user.preferences.body_background.present?
      background = (@user || user).preferences.body_background
      if background =~ %r{^https?://}
        remove_suspicious_css "background: url(#{background}) fixed no-repeat;"
      else
        remove_suspicious_css "background: #{background};"
      end
    end
  end

  def remove_suspicious_css css
    evil = [
      /(\bdata:\b|eval|cookie|\bwindow\b|\bparent\b|\bthis\b)/i, # suspicious javascript-type words
      /behaviou?r|expression|moz-binding|@import|@charset|(java|vb)?script|[\<]|\\\w/i,
      /[\<>]/, # back slash, html tags,
      #/[\x7f-\xff]/, # high bytes -- suspect
      /[\x00-\x08\x0B\x0C\x0E-\x1F]/, #low bytes -- suspect
      /&\#/, # bad charset
    ]
    evil.each {|regex| css.gsub! regex, '' }
    css
  end
end
