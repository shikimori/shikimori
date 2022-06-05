describe Animes::RefreshScoresWorker do
  before { allow(DbEntry::RefreshScore).to receive :call }
  subject! do
    described_class.new.perform type, entry_id, global_average
  end
  let(:type) { anime.class.name }
  let(:entry_id) { anime.id }
  let(:global_average) { '9.9' }

  context 'found entry' do
    let(:anime) { create :anime }
    it do
      expect(DbEntry::RefreshScore)
        .to have_received(:call)
        .with(entry: anime, global_average: global_average.to_f)
    end
  end

  context 'not found entry' do
    let(:anime) { build_stubbed :anime }
    it { expect(DbEntry::RefreshScore).to_not have_received :call }
  end
end
