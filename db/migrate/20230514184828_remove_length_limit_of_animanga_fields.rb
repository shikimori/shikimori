class RemoveLengthLimitOfAnimangaFields < ActiveRecord::Migration[6.1]
  def change
    %i[animes mangas].each do |table|
      %i[name kind status rating russian torrents_name imageboard_tag english japanese season franchise].each do |field|
        next if field.in?(%i[season torrents_name]) && table == :mangas
        change_column table, field, :string
      end
    end
  end
end
