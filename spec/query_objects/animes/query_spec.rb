describe Animes::Query do
  subject do
    described_class.fetch(
      scope: scope,
      params: params,
      user: user
    )
  end
  let(:scope) { Anime.all }
  let(:params) { {} }
  let(:user) { nil }

  let(:anime) { build_stubbed :anime }

  context 'no params' do
    it { is_expected.to eq Anime.all }
  end

  context '#by_kind' do
    let(:params) { { kind: 'zzz' } }
    before do
      allow(Animes::Filters::ByKind)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end

  context '#by_rating' do
    let(:params) { { rating: 'zzz' } }
    before do
      allow(Animes::Filters::ByRating)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end

  context '#by_duration' do
    let(:params) { { duration: 'zzz' } }
    before do
      allow(Animes::Filters::ByDuration)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end
end
