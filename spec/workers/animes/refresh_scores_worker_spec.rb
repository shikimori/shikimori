describe Animes::RefreshScoresWorker do
  before { allow(Anime::RefreshScore).to receive :call }
  subject! do
    described_class.new.perform type, entry_id, global_average
  end
  let(:type) { anime.class.name }
  let(:entry_id) { anime.id }
  let(:global_average) { '9.9' }

  context 'found entry' do
    let(:anime) { create :anime }
    it do
      expect(Anime::RefreshScore)
        .to have_received(:call)
        .with(anime, global_average.to_f)
    end
  end

  context 'not found entry' do
    let(:anime) { build_stubbed :anime }
    it { expect(Anime::RefreshScore).to_not have_received :call }
  end
end
