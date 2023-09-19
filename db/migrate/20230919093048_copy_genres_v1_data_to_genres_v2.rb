class CopyGenresV1DataToGenresV2 < ActiveRecord::Migration[7.0]
  def change
    GenreV2.where(description: '').each do |genre_v2|
      genre = Genre.find_by(kind: genre_v2.entry_type.downcase, name: genre_v2.name)
      next unless genre
      genre_v2.update! description: genre.description
    end

    %w[Anime Manga].each do |entry_type|
      mystery = GenreV2.find_by(name: 'Mystery', entry_type:)
      detective = GenreV2.find_by(name: 'Detective', entry_type:)

      detective&.update description: mystery.description
      mystery&.update description: ''
    end

    GenreV2.find_each do |genre_v2|
      genre = Genre.find_by(kind: genre_v2.entry_type.downcase, russian: genre_v2.russian)
      next unless genre

      genre_v2.update seo: genre.seo
    end
  end
end
