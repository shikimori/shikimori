class MigrateUserStylesPreferencesToStyleEntities < ActiveRecord::Migration
  def up
    styles = User.includes(:preferences).map do |user|
      user.styles.build name: '', css: css(user.preferences)
    end
    Style.import styles
    User.connection.execute <<-SQL
      update users
        set style_id = s.id
      from
        users u
        inner join styles s
          on s.owner_id = u.id and s.owner_type='User'
    SQL
  end

  def down
    Style.delete_all
    User.update_all style_id: nil
  end

private

  def css preferences
    styles = []

    if preferences.page_border
      styles << Style::PAGE_BORDER_CSS
    end

    if preferences.page_background.to_f > 0
      color = 255 - preferences.page_background.to_f.ceil
      styles << Style::PAGE_BORDER_CSS % [color, color, color]
    end

    if preferences.body_background.present?
      styles << Style::BODY_BACKGROUND_CSS % [background_css(preferences)]
    end

    styles.join("\n")
  end

  def background_css preferences
    background = preferences.body_background

    if background =~ %r{\A(https?:)?//}
      url = UrlGenerator.instance.camo_url background
      "background: url(#{url}) fixed no-repeat;"
    else
      fixed_background = background.gsub(BbCodes::UrlTag::REGEXP) do
        UrlGenerator.instance.camo_url $LAST_MATCH_INFO[:url]
      end
      "background: #{fixed_background};"
    end
  end
end
