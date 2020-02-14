describe Animes::Query do
  subject do
    described_class.fetch(
      klass: klass,
      params: params,
      user: user
    )
  end
  let(:klass) { Anime }
  let(:params) { {} }
  let(:user) { nil }

  let(:anime) { build_stubbed :anime }

  context 'no params' do
    it { is_expected.to eq Anime.all }
  end

  context '#by_kind' do
    let(:params) { { kind: 'tv' } }
    before do
      allow(Animes::Filters::ByKind)
        .to receive(:call)
        .with(Anime.all, 'tv')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end

  context '#by_rating' do
    let(:params) { { rating: 'tv' } }
    before do
      allow(Animes::Filters::ByRating)
        .to receive(:call)
        .with(Anime.all, 'tv')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end
end
