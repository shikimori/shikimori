describe StatisticsController do
  describe '#index' do
    subject { get :index }
    let!(:topic) { create :topic, id: Topic::TOPIC_IDS[:anime_industry][:ru] }
    it { is_expected.to have_http_status :success }
  end

  describe '#lists' do
    subject { get :lists }
    before do
      allow(controller)
        .to receive(:list_stats)
        .and_return({})
      allow(controller)
        .to receive(:duration_stats)
        .and_return({})
    end
    it { is_expected.to have_http_status :success }
  end
end
