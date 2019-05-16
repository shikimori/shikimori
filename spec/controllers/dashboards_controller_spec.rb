describe DashboardsController do
  describe '#show' do
    let!(:topic) { create :topic, id: Topic::TOPIC_IDS[:socials][:ru] }
    subject! { get :show }
    it { expect(response).to have_http_status :success }
  end
end
