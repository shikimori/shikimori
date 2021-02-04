describe Animes::RefreshStatsWorker do
  subject { described_class.new.perform kind }
  before { allow(Animes::RefreshStats).to receive(:call).and_return :zzz }

  context 'anime' do
    let(:kind) { 'anime' }
    it do
      is_expected.to eq :zzz
      expect(Animes::RefreshStats).to have_received(:call).with Anime.all
    end
  end

  context 'manga' do
    let(:kind) { 'anime' }
    it do
      is_expected.to eq :zzz
      expect(Animes::RefreshStats).to have_received(:call).with Manga.all
    end
  end
end
