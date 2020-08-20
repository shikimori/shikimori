class MigrateGeneratedTagInStyles < ActiveRecord::Migration[5.2]
  def up
    Style.find_each do |style|
      style.update css: fix(style.css)
    end
  end

private

  def fix css
    css
      .gsub(%r{ /\*\s\[generated=(\w+)\]\s\*/[ \r\n]* }mix, '/* AUTO=\1 */ ')
      .gsub(%r{ /\*\s\[/generated\]\s\*/[ \r\n]*}mix, '')
  end
end
