class AddLimitToTextFields < ActiveRecord::Migration[5.2]
  SCHEMA = [
    [%i[animes mangas characters], %i[description_ru description_ru], 16384],
    [%i[animes mangas], %i[name english russian japanese], 255],
    [:characters, %i[name japanese fullname], 255],
    [:characters, %i[name japanese], 255],
    [:abuse_requests, :reason, 4096]
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
