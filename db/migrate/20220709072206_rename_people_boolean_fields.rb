class RenamePeopleBooleanFields < ActiveRecord::Migration[6.1]
  def change
    %i[producer mangaka seyu].each do |field|
      rename_column :people, field, :"is_#{field}"
      change_column_null :people, :"is_#{field}", false
    end
  end
end
