class BbCodes::CachedText
  method_object :text

  MINIMAL_CACHE_LIMIT = 36

  def call
    return @text if @text.blank?

    if @text.size > MINIMAL_CACHE_LIMIT
      Rails.cache.fetch [:text_html, @text.size, XXhash.xxh32(@text)] do
        text_html
      end
    else
      text_html
    end
  end

private

  def text_html
    BbCodes::Text.call @text
  end
end
