describe RecommendationsController do
  %w[anime manga].each do |type|
    describe type do
      describe '#index' do
        context 'with_params' do
          before do
            get :index,
              params: {
                klass: type,
                metric: 'pearson_z',
                threshold: RecommendationsController::THRESHOLDS[type.classify.constantize]['pearson_z'].first
              }
          end
          it { expect(response).to have_http_status :success }
        end

        describe 'witout_params' do
          before { get :index, params: { klass: type } }
          it { should respond_with :redirect }
        end
      end

      describe '#favourites' do
        before { get :favourites, params: { klass: type } }
        it { expect(response).to have_http_status :success }
      end
    end
  end
end
