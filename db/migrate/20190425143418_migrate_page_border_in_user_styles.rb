class MigratePageBorderInUserStyles < ActiveRecord::Migration[5.2]
  def up
    Style.connection.execute(
      <<~SQL
        update
          styles
        set
          css = replace(css, '/* AUTO=page_border */ .l-page:before, .l-page:after, .l-footer:before, .l-footer:after { display: block; }', '/* AUTO=page_border */ .l-page { outline: 20px solid rgba(255, 255, 255, 0.3); margin-bottom: 20px; }')
        where
          css != ''
      SQL
    )
  end

  def down
    Style.connection.execute(
      <<~SQL
        update
          styles
        set
          css = replace(css, '/* AUTO=page_border */ .l-page { outline: 20px solid rgba(255, 255, 255, 0.3); margin-bottom: 20px; }', '/* AUTO=page_border */ .l-page:before, .l-page:after, .l-footer:before, .l-footer:after { display: block; }')
        where
          css != ''
      SQL
    )
  end
end
