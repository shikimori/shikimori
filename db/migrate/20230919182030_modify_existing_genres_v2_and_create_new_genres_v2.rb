class ModifyExistingGenresV2AndCreateNewGenresV2 < ActiveRecord::Migration[7.0]
  def up
    GenreV2.where(name: 'Award Winning').update_all(
      kind: Types::GenreV2::Kind[:theme],
      position: 1000
    )
    GenreV2.where(name: ['Hentai', 'Erotica']).update_all is_censored: true
  end
end
