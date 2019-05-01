class Style < ApplicationRecord
  OWNER_TYPES = [User.name, Club.name]

  belongs_to :owner, polymorphic: true, inverse_of: :style, optional: true

  validates :owner, presence: true
  validates :owner_type, inclusion: { in: OWNER_TYPES }

  PAGE_BORDER_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=page_border */ .l-page { outline: 20px solid rgba(255, 255, 255, 0.3); margin-bottom: 20px; }
  CSS

  STICKY_MENU_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=sticky_menu */ @media screen and (min-width: 1025px) { .l-top_menu-v2 { position: sticky; top: 0; } .l-top_menu-v2 .active .submenu { max-height: calc(100vh - 46px); overflow: auto; } }
  CSS

  PAGE_BACKGROUND_COLOR_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=page_background_color */ .l-page { background-color: rgba(%d, %d, %d, %d); } .b-ajax:before { background: rgba(%d, %d, %d, 0.75); }
  CSS

  BODY_BACKGROUND_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* AUTO=body_background */ body { background: %s; }
  CSS
  MEDIA_QUERY_CSS = '@media only screen and (min-width: 1024px)'

  def compiled_css
    strip_comments(media_query(sanitize(camo_images(css))))
  end

private

  def media_query css
    if css.blank? || css.gsub(%r{^/\* AUTO=.*}, '').include?('@media')
      css
    else
      "#{MEDIA_QUERY_CSS} { #{css} }"
    end
  end

  def camo_images css
    css.gsub(BbCodes::Tags::UrlTag::URL) do
      url = $LAST_MATCH_INFO[:url]
      if url =~ /(?<quote>["'`])$/
        quote = $LAST_MATCH_INFO[:quote]
        url = url.gsub(/["'`]$/, '')
      end

      "#{UrlGenerator.instance.camo_url url}#{quote}"
    end
  end

  def strip_comments css
    css.gsub(%r{/\* .*? \*/[\n\r]*}mix, '')
  end

  def sanitize css
    Misc::SanitizeEvilCss.call(css).strip.gsub(/;;+/, ';').strip
  end
end
