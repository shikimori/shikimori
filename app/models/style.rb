class Style < ActiveRecord::Base
  OWNER_TYPES = [User.name]

  belongs_to :owner, polymorphic: true, inverse_of: :style

  validates :owner, presence: true
  validates :owner_type, inclusion: { in: OWNER_TYPES }

  PAGE_BORDER_CSS = <<-CSS.strip.gsub(/^ +/, '')
    /* GENERATED: page_border */
    .l-page:before, .l-page:after, .l-footer:before, .l-footer:after { display: block; }
  CSS

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
