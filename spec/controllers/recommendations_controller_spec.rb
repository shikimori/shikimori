describe RecommendationsController do
  describe '#index' do
    describe 'anime' do
      let(:type) { 'anime' }
      context 'with_params' do
        before { get :index, klass: type, metric: 'pearson', threshold: RecommendationsController::THRESHOLDS[type.capitalize.constantize].first }
        it { expect(response).to have_http_status :success }
      end

      describe 'witout_params' do
        before { get :index, klass: type }
        it { should respond_with :redirect }
      end
    end

    describe 'manga' do
      let(:type) { 'manga' }
      context 'with_params' do
        before { get :index, klass: type, metric: 'pearson', threshold: RecommendationsController::THRESHOLDS[type.capitalize.constantize].first }
        it { expect(response).to have_http_status :success }
      end

      describe 'witout_params' do
        before { get :index, klass: type }
        it { should respond_with :redirect }
      end
    end
  end

  describe '#favourites' do
    before { get :favourites, klass: 'anime' }
    it { expect(response).to have_http_status :success }
  end
end
