module SiteHelper
  # ссылка на источник
  def source_link source
    sanitized_source = h(source)
    if sanitized_source =~ /(.*?)(https?:\/\/.*)/
      prefix = ($1 || '').strip
      url = $2

      domain = url.sub(/^https?:\/\/(?:www\.)?([^\/]+)\/?.*/, '\1')
      if prefix.blank?
        "<a class='b-link' href=\"#{url}\">#{domain}</a>"
      else
        "#{prefix} <a class='b-link' href=\"#{url}\">#{domain}</a>"
      end
    else
      sanitized_source
    end
  end
end
