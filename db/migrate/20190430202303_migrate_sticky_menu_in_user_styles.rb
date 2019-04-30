class MigrateStickyMenuInUserStyles < ActiveRecord::Migration[5.2]
  def up
    Style.connection.execute(
      <<~SQL
        update
          styles
        set
          css = replace(css, '/* AUTO=sticky_menu */ .l-top_menu-v2 { position: sticky; top: 0; }', '/* AUTO=sticky_menu */ .l-top_menu-v2 { position: sticky; top: 0; } .l-top_menu-v2 .active .submenu { max-height: calc(100vh - 46px); overflow: auto; }')
        where
          css like '%sticky_menu%'
      SQL
    )
  end

  def down
    Style.connection.execute(
      <<~SQL
        update
          styles
        set
          css = replace(css, '/* AUTO=sticky_menu */ .l-top_menu-v2 { position: sticky; top: 0; } .l-top_menu-v2 .active .submenu { max-height: calc(100vh - 46px); overflow: auto; }', '/* AUTO=sticky_menu */ .l-top_menu-v2 { position: sticky; top: 0; }')
        where
          css like '%sticky_menu%'
      SQL
    )
  end
end
