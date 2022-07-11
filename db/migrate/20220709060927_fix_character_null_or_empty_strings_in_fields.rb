class FixCharacterNullOrEmptyStringsInFields < ActiveRecord::Migration[6.1]
  FIELDS = %i[name russian japanese fullname description_en description_ru imageboard_tag] 

  def change
    FIELDS.each do |field|
      Character.where(field => nil).update_all field => ''
      change_column_default :characters, field, from: nil, to: ''
      change_column_null :characters, field, false
    end
  end

  def down
    FIELDS.each do |field|
      change_column_null :characters, field, true
      Character.where(field => '').update_all field => nil
      change_column_default :characters, field, from: '', to: nil
    end
  end
end
