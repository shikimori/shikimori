class AddLimitToTextFieldsV2 < ActiveRecord::Migration[5.2]
  SCHEMA = [
    [:articles, :body, 140_000],
    [:bans, :reason, 4096],
    [:club_pages, :text, 500_000],
    [:collections, :text, 400_000],
    [:comments, :body, 64_000],
    [:message, :body, 110_000],
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
