class AddEroticaGenre < ActiveRecord::Migration[5.2]
  def up
    return if Rails.env.test?

    %i[anime manga].each_with_index do |kind, index|
      Genre.create!(
        id: Genre::EROTICA_IDS[index],
        name: 'Erotica',
        russian: 'Эротика',
        position: Genre.find_by(name: 'Hentai', kind: kind).position - 10,
        kind: kind,
        seo: 0,
        mal_id: 49
      )
    end
    ActiveRecord::Base.connection.reset_pk_sequence!(:genres)
  end

  def down
    Genre.where(mal_id: 49).destroy_all
  end
end
