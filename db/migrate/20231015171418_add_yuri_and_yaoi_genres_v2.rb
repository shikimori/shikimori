class AddYuriAndYaoiGenresV2 < ActiveRecord::Migration[7.0]
  def up
    return if Rails.env.test?

    %w[Anime Manga].each do |entry_type|
      %w[Yaoi Yuri].each do |name|
        GenreV2
          .find_or_initialize_by(name:, entry_type:)
          .update! Genre.find_by(name:).attributes.except('id').merge(mal_id: -1, kind: 'genre', entry_type:)
      end
    end
  end
end
