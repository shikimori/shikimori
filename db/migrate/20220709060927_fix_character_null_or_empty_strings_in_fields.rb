class FixCharacterNullOrEmptyStringsInFields < ActiveRecord::Migration[6.1]
  FIELDS = %i[name russian japanese fullname description_en description_ru imageboard_tag] 

  def up
    FIELDS.each do |field|
      change_column_default :characters, field, from: nil, to: ''
      change_column_null :characters, field, false
    end
  end

  def down
    FIELDS.each do |field|
      change_column_null :characters, field, true
      change_column_default :characters, field, from: '', to: nil
    end
  end
end
