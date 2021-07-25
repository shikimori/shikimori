class AddLimitToTextFields < ActiveRecord::Migration[5.2]
  SCHEMA = [
    [%i[animes mangas], %i[name english russian japanese franchise], 255],
    [:genres, :description, 4096],
    [:animes, :season, 255],
    [:characters, %i[name japanese fullname], 255],
    [:characters, %i[name japanese], 255],
    [:abuse_requests, :reason, 4096],
    [
      %i[
        articles
        club_pages
        collections
        coub_tags
        oauth_applications
        publishers
        studios
      ],
      :name,
      255
    ],
    [
      %i[animes mangas oauth_applications studios],
      %i[description_ru description_en],
      16384
    ],
    [
      %i[contests characters],
      %i[description_ru description_en],
      32768
    ],
    [:clubs, :description, 600_000],
    [:studios, %i[short_name japanese ani_db_name], 500_000],
    [:cosplay_galleries, %i[description description_cos_rain], 16384]
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
