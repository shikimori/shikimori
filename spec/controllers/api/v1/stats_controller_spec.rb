describe Api::V1::StatsController, :show_in_doc do
  describe '#active_users' do
    let!(:user_rate) { create :user_rate, user:, status: :completed }
    let(:user) { create :user, last_online_at: Time.zone.now }
    before { get :active_users, format: :json }

    it { expect(response).to have_http_status :success }
  end
end
