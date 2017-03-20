class Style < ApplicationRecord
  OWNER_TYPES = [User.name, Club.name]

  belongs_to :owner, polymorphic: true, inverse_of: :style

  validates :owner, presence: true
  validates :owner_type, inclusion: { in: OWNER_TYPES }

  PAGE_BORDER_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=page_border */ .l-page:before, .l-page:after, .l-footer:before, .l-footer:after { display: %s; }
  CSS

  PAGE_BACKGROUND_COLOR_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=page_background_color */ .l-page { background-color: rgba(%d, %d, %d, %d); }
  CSS

  BODY_BACKGROUND_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=body_background */ body { background: %s; }
  CSS
  MEDIA_QUERY_CSS = '@media only screen and (min-width: 1024px)'

  def compiled_css
    media_query(sanitize(camo_images(strip_comments(css))))
  end

private

  def media_query css
    if css.include?('@media') || css.blank?
      css
    else
      "#{MEDIA_QUERY_CSS} { #{css} }"
    end
  end

  def camo_images css
    css.gsub(BbCodes::UrlTag::URL) do
      UrlGenerator.instance.camo_url $LAST_MATCH_INFO[:url]
    end
  end

  def strip_comments css
    css.gsub(%r{/\* .*? \*/[\n\r]*}mix, '')
  end

  def sanitize css
    Misc::SanitizeEvilCss.call(css).strip.gsub(/;;+/, ';').strip
  end
end
