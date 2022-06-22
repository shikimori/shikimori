describe Mangas::NekoScope do
  subject { described_class.call }

  let!(:manga_released) { create :manga, :released }
  let!(:ranobe_ongoing) { create :ranobe, :ongoing }
  let!(:manga_ongoing) { create :manga, :ongoing }
  let!(:manga_anons) { create :anime, :anons }

  it { is_expected.to eq [manga_released, ranobe_ongoing, manga_ongoing] }
end
