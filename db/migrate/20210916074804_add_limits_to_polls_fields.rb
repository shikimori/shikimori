class AddLimitsToPollsFields < ActiveRecord::Migration[5.2]
  SCHEMA = [
    [:polls, :name, 255],
    [:polls, :text, 25_000],
  ]

  def up
    SCHEMA.each do |(tables, fields, limit)|
      Array(tables).each do |table|
        Array(fields).each do |field|
          change_column table, field, :string, limit: limit
        end
      end
    end
  end

end
