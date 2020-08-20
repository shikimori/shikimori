class ImportStylesForUsers < ActiveRecord::Migration[5.2]
  DEFAULT_BACKGROUND_REGEXP = %r{
    \A
    url\(
      (?:
        /assets/background/\w+\.png
        |
        #{BbCodes::Tags::UrlTag::URL.source}
      )
    \)
    (?: \s* fixed )?
    (?: \s* (?:no-)? repeat )?
    (?: \s* fixed )?
    \Z
  }mix

  def up
    puts 'generating styles'
    styles = User.includes(:preferences).map do |user|
      user.styles.build name: '', css: css(user.preferences)
    end
    puts 'importing styles'
    Style.import styles, validate: false
  end

  def down
    Style.delete_all
  end

private

  def css preferences
    styles = []

    styles << (Style::PAGE_BORDER_CSS + "\n") % [
      preferences.page_border ? 'block' : 'none'
    ]

    if preferences.page_background.to_f > 0
      color = 255 - preferences.page_background.to_f.ceil
      styles << (Style::PAGE_BACKGROUND_COLOR_CSS + "\n") % [
        color,
        color,
        color,
        1
      ]
    end

    if preferences.body_background.present?
      styles.concat background_styles(preferences.body_background)
    end

    styles.join("\n").strip.gsub(';;', ';')
  end

  def background_styles background
    styles = []

    if background =~ %r{\A(https?:)?//}
      styles << (Style::BODY_BACKGROUND_CSS + "\n") % [
        "url(#{background}) fixed no-repeat"
      ]

    elsif background.include? ';'
      backgrounds = background.split(';').map(&:strip)
      styles << body_background(backgrounds[0])

      if backgrounds.many?
        styles << "body {\n  #{fix_urls backgrounds[1..-1].join(";\n  ").strip};\n}"
      end
    else
      styles << body_background(background)
    end

    styles
  end

  def body_background style
    if style.include? ','
      "body {\n  background: #{style};\n}"
    elsif style =~ DEFAULT_BACKGROUND_REGEXP
      (Style::BODY_BACKGROUND_CSS + "\n") % [style]
    else
      "body {\n  background: #{style};\n}"
    end
  end

  def fix_urls css
    css.gsub(/
      url\("
        ([^\n\r")]*)
      "\)
    /mix, 'url(\1)')
  end
end
