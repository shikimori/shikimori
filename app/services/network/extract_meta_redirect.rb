class Network::ExtractMetaRedirect
  method_object :html

  def call
    meta = Nokogiri::HTML(@html).css('meta[http-equiv="refresh"]').first
    return unless meta

    content = meta.attr 'content'
    return if content.blank?

    url = content.split(';').last.strip
    clean_url = url.gsub(/url=/i, '').strip.gsub(/^['"]|['"]$/, '').strip

    clean_url if clean_url.present?
  end
end
