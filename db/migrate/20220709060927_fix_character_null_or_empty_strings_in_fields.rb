class FixCharacterNullOrEmptyStringsInFields < ActiveRecord::Migration[6.1]
  def change
    %i[name russian japanese fullname description_en description_ru imageboard_tag].each do |field|
      change_column_default :characters, field, from: nil, to: ''
      change_column_null :characters, field, true
    end
  end
end
