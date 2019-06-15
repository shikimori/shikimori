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

  def compiled_css
    return if css.blank?

    if attributes['compiled_css'].nil?
      self.updated_at = Time.zone.now
      update Styles::Compile.call css
    end

    attributes['compiled_css']
  end
end
