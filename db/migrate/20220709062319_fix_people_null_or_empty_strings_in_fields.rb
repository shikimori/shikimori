class FixPeopleNullOrEmptyStringsInFields < ActiveRecord::Migration[6.1]
  FIELDS = %i[name russian japanese website]

  def change
    FIELDS.each do |field|
      Person.where(field => nil).update_all field => ''
      change_column_default :people, field, from: nil, to: ''
      change_column_null :people, field, false
    end
  end

  def down
    FIELDS.each do |field|
      change_column_null :people, field, true
      Person.where(field => '').update_all field => nil
      change_column_default :people, field, from: '', to: nil
    end
  end
end
