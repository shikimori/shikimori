class FixStylesV2 < ActiveRecord::Migration[5.2]
  def up
    Style.where("css like '%menu-dropdown%'").find_each do |style|
      style.update css: style.css.gsub(/menu-dropdown(.\w+|:\w+)?\s*>\s*button/, 'menu-dropdown\1 > span')
    end
  end

  def down
    Style.where("css like '%menu-dropdown%'").find_each do |style|
      style.update css: style.css.gsub(/menu-dropdown(.\w+|:\w+)?\s*>\s*span/, 'menu-dropdown\1 > button')
    end
  end
end
