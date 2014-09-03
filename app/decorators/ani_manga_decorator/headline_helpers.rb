module AniMangaDecorator::HeadlineHelpers
  def headline
    headline_array.join(' <span class="sep inline">/</span> ').html_safe
  end

private
  def headline_array
    if !h.user_signed_in? || (h.user_signed_in? && !h.current_user.preferences.russian_names?)
      [name, russian].compact
    else
      [russian, name].compact
    end
  end
end
