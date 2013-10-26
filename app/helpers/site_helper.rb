module SiteHelper
  CensoredUserIds = Set.new [4357]

  # урл аватарки
  def gravatar_url(user, size)
    if user.avatar.exists?
      # для поставивших пахабные аватарки меняем аватарку, но поставившему отображем его собственную
      if CensoredUserIds.include?(user.id) && (!user_signed_in? || (user_signed_in? && !CensoredUserIds.include?(current_user.id)))
        "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest('takandar+censored@gmail.com'), size]
      else
        user.avatar.url "x#{size}".to_sym
      end
    else
      "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest(user.email.downcase), size]
    end
  end

  # ссылка на источник
  def source_link(source)
    if source =~ /(.*?)(https?:\/\/.*)/
      prefix = ($1 || '').strip
      url = $2

      domain = url.sub(/^https?:\/\/(?:www\.)?([^\/]+)\/?.*/, '\1')
      prefix.blank? ? "<a href=\"#{url}\">#{domain}</a>" : "#{prefix} <a href=\"#{url}\">#{domain}</a>"
    else
      source
    end
  end
end
