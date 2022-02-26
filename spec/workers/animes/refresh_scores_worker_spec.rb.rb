describe Animes::RefreshScoresWorker do
  subject { described_class.new.perform entry_class, entry_id, global_average }
  before { allow(Anime::RefreshScores).to receive(:call).and_return :zzz }

  let(:anime) { create :anime }
  let(:manga) { create :manga }

  context 'anime' do
    let(:entry_class) { Anime }
    let(:entry_id) { anime.id }
    let(:global_average) { 0.77 }

    it do
      is_expected.to eq :zzz
      expect(Anime::RefreshScores).to have_received(:call).with anime, 0.77
    end
  end

  context 'manga' do
    let(:entry_class) { Manga }
    let(:entry_id) { manga.id }
    let(:global_average) { 0.77 }

    it do
      is_expected.to eq :zzz
      expect(Anime::RefreshScores).to have_received(:call).with manga, 0.77
    end
  end
end
