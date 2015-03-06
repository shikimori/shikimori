describe RecommendationsController do
  ['anime', 'manga'].each do |type|
    describe type do
      describe '#index' do
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
  end
end
