describe AnimeStatusQuery do
  let(:query) { AnimeStatusQuery.new Anime.order(:id) }
  let!(:anons) { create :anime, :anons }
  let!(:ongoing) { create :anime, :ongoing }
  let!(:released_latest) { create :anime, :released, released_on: AnimeStatusQuery::LATEST_INTERVAL.ago + 1.day }
  let!(:released_old) { create :anime, :released, released_on: AnimeStatusQuery::LATEST_INTERVAL.ago - 1.day }

  describe '#by_status' do
    let(:result) { query.by_status status }

    context 'anons' do
      let(:status) { 'anons' }
      it { expect(result).to eq [anons] }
    end

    context 'ongoing' do
      let(:status) { 'ongoing' }
      it { expect(result).to eq [ongoing] }
    end

    context 'released' do
      let(:status) { 'released' }
      it { expect(result).to eq [released_latest, released_old] }
    end

    context 'latest' do
      let(:status) { 'latest' }
      it { expect(result).to eq [released_latest] }
    end

    context 'bad status' do
      let(:status) { :zzz }
      it { expect{result}.to raise_error ArgumentError }
    end
  end
end
