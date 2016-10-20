class Style < ActiveRecord::Base
  belongs_to :owner, polymorphic: true, inverse_of: :style

  validates :owner, presence: true

  # rubocop:disable LineLength
  PAGE_BORDER_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* GENERATED: page_border */
    .l-page:before, .l-page:after, .l-footer:before, .l-footer:after { display: block; }
  CSS
  # rubocop:enable LineLength

  BODY_OPACITY_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* GENERATED: body_opacity */
    .l-page { background-color: rgba(%d, %d, %d, 1); }
  CSS

  BODY_BACKGROUND_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* GENERATED: body_background */
    body { %s; }
  CSS

  def safe_css
    Misc::SanitizeEvilCss.call(css).strip.gsub(/;;+/, ';').strip
  end
end
