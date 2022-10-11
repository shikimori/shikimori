describe Animes::SmotretAnimeId do
  subject { described_class.call anime }
  let(:anime) { create :anime }

  context 'has link' do
    let!(:external_link) do
      create :external_link,
        source: :smotret_anime,
        kind: :smotret_anime,
        entry: anime,
        url: url
    end
    let(:url) do
      format(SmotretAnime::LinkWorker::ANIME365_URL, smotret_anime_id: smotret_anime_id)
    end

    context 'has id' do
      let(:smotret_anime_id) { 123 }
      it { is_expected.to eq 123 }
    end

    context 'no id' do
      let(:url) { 'NONE' }
      it { is_expected.to be_nil }
    end
  end

  context 'no link' do
    it { is_expected.to be_nil }
  end
end
