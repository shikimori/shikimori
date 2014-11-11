describe RecommendationsController do
  let(:user) { create :user }
  let(:metric) { :pearson }
  let(:threshold) { 45 }
  let(:klass) { Anime }
  let(:fetcher) { Recommendations::Fetcher.new user, klass, metric, threshold }

  describe 'fetch' do
    subject { fetcher.fetch }

    context 'no user user' do
      let(:user) { nil }
      it { should be_empty }
    end

    context 'not enough user data' do
      it { should be_empty }
    end

    context 'recommendations not calculated yet' do
      before do
        user.stub_chain(:anime_rates, :count).and_return Recommendations::RatesFetcher::MinimumScores
        user.stub_chain(:history, :count).and_return Recommendations::RatesFetcher::MinimumScores
        RecommendationsWorker.should_receive :perform_async
      end
      it { should be_nil }
    end

    context 'recommendations have been calculated' do
      let(:rankings) { {1=>2, 3=>4} }
      before do
        user.stub_chain(:anime_rates, :count).and_return Recommendations::RatesFetcher::MinimumScores
        user.stub_chain(:history, :count).and_return Recommendations::RatesFetcher::MinimumScores
        Rails.cache.stub(:read).and_return rankings
      end

      it { should eql rankings }
    end
  end
end
