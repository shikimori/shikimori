module SiteHelper
  # ссылка на источник
  def source_link source
    if source =~ /(.*?)(https?:\/\/.*)/
      prefix = ($1 || '').strip
      url = $2

      domain = url.sub(/^https?:\/\/(?:www\.)?([^\/]+)\/?.*/, '\1')
      if prefix.blank?
        "<a class='b-link' href=\"#{h(url)}\">#{domain}</a>"
      else
        "#{prefix} <a class='b-link' href=\"#{h(url)}\">#{domain}</a>"
      end
    else
      source
    end
  end
end
