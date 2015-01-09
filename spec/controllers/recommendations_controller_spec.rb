describe RecommendationsController do
  ['anime', 'manga'].each do |type|
    describe type do
      describe '#index' do
        context 'with_params' do
          before { get :index, klass: type, metric: 'pearson', threshold: RecommendationsController::THRESHOLDS[Anime].first }
          it { should respond_with :success }
        end

        describe 'witout_params' do
          before { get :index, klass: type }
          it { should respond_with :redirect }
        end
      end
    end
  end
end
