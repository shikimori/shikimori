describe Animes::NekoScope do
  subject { described_class.call }

  let!(:anime_1) { create :anime, kind: :tv }
  let!(:anime_2) { create :anime, kind: :movie }
  let!(:anime_3) { create :anime, kind: :special }
  let!(:anime_4) { create :anime, kind: :music }

  it { is_expected.to eq [anime_1, anime_2, anime_3, anime_4] }
end
