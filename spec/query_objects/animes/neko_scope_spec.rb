describe Animes::NekoScope do
  subject { described_class.call }

  let!(:anime_tv) { create :anime, :released, kind: :tv }
  let!(:anime_movie) { create :anime, :released, kind: :movie }
  let!(:anime_special) { create :anime, :released, kind: :special }
  let!(:anime_music) { create :anime, :released, kind: :music }
  let!(:anime_released) { create :anime, :released }
  let!(:anime_ongoing) { create :anime, :ongoing }
  let!(:anime_anons) { create :anime, :anons }

  it do
    is_expected.to eq [
      anime_tv,
      anime_movie,
      anime_special,
      anime_music,
      anime_released,
      anime_ongoing
    ]
  end
end
