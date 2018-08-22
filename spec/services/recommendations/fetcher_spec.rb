describe Recommendations::Fetcher do
  let(:metric) { :pearson }
  let(:threshold) { 45 }
  let(:klass) { Anime }

  before { stub_const 'UserDataFetcherBase::MINIMUM_SCORES', minimum_scores }
  let(:minimum_scores) { 0 }

  subject do
    described_class.call(
      user: user,
      klass: klass,
      metric: metric,
      threshold: threshold
    )
  end

  context 'no user user' do
    let(:user) { nil }
    it { is_expected.to be_empty }
  end

  context 'not enough user data' do
    let(:minimum_scores) { 999 }
    it { is_expected.to be_empty }
  end

  context 'recommendations not calculated yet' do
    before { allow(RecommendationsWorker).to receive :perform_async }
    it { is_expected.to be_nil }
  end

  context 'recommendations have been calculated' do
    let(:anime_1) { create :anime }
    let(:anime_2) { create :anime }
    let(:rankings) { { anime_1.id => 2, anime_2.id => 4 } }

    before { allow(Rails.cache).to receive(:read).and_return rankings }

    it { is_expected.to eq rankings.keys }

    context 'empty recommendations' do
      let(:rankings) { [] }
      it { is_expected.to eq [] }
    end

    context 'ignored recommendation' do
      let!(:recommendation_ignore_1) do
        create :recommendation_ignore,
          target: anime_1,
          user: user
      end
      let!(:recommendation_ignore_2) do
        create :recommendation_ignore,
          target: anime_2,
          user: create(:user)
      end

      it { is_expected.to eq [anime_2.id] }
    end

    context 'in_list excluded' do
      let!(:recommendation_ignore_1) do
        create :recommendation_ignore,
          target: anime_1,
          user: user
      end
      let!(:recommendation_ignore_2) do
        create :recommendation_ignore,
          target: anime_2,
          user: create(:user)
      end

      it { is_expected.to eq [anime_2.id] }
    end
  end
end
