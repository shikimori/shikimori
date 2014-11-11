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
        allow(user).to receive_message_chain(:anime_rates, :count).and_return Recommendations::RatesFetcher::MinimumScores
        allow(user).to receive_message_chain(:history, :count).and_return Recommendations::RatesFetcher::MinimumScores
        expect(RecommendationsWorker).to receive :perform_async
      end
      it { should be_nil }
    end

    context 'recommendations have been calculated' do
      let(:rankings) { {1=>2, 3=>4} }
      before do
        allow(user).to receive_message_chain(:anime_rates, :count).and_return Recommendations::RatesFetcher::MinimumScores
        allow(user).to receive_message_chain(:history, :count).and_return Recommendations::RatesFetcher::MinimumScores
        allow(Rails.cache).to receive(:read).and_return rankings
      end

      it { should eql rankings }
    end
  end
end
