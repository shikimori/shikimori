# describe Api::V1::AchievementsController, :show_in_doc do
describe Api::V1::AchievementsController do
  describe '#index' do
    let!(:achievement_1) { create :achievement, user: }
    let!(:achievement_2) { create :achievement, user: create(:user) }
    before { get :index, params: { user_id: user.id }, format: :json }

    it do
      expect(collection).to eq [achievement_1]
      expect(json).to have(1).item
      expect(response).to have_http_status :success
    end
  end
end
