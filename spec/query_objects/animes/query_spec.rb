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

  context '#by_achievement' do
    let(:params) { { achievement: 'zzz' } }
    before do
      allow(Animes::Filters::ByAchievement)
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

  context '#by_franchise' do
    let(:params) { { franchise: 'zzz' } }
    before do
      allow(Animes::Filters::ByFranchise)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end

  context '#by_ids' do
    let!(:anime_1) { create :anime }
    let!(:anime_2) { create :anime }
    let!(:anime_3) { create :anime }

    let(:scope) { Anime.order :id }
    let(:params) do
      [
        { ids: "#{anime_3.id},#{anime_2.id}" },
        [anime_3.id, anime_2.id]
      ][0]
    end

    it { is_expected.to eq [anime_2, anime_3] }
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

  context '#by_score' do
    let(:params) { { score: 'zzz' } }
    before do
      allow(Animes::Filters::ByScore)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end

  context '#by_status' do
    let(:params) { { status: 'zzz' } }
    before do
      allow(Animes::Filters::ByStatus)
        .to receive(:call)
        .with(Anime.all, 'zzz')
        .and_return [anime]
    end

    it { is_expected.to eq [anime] }
  end
end
