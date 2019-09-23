describe Api::V1::BansController, :show_in_doc do
  describe '#index' do
    let!(:ban_1) { create :ban, user: user, moderator: user, comment: create(:comment, user: user) }
    let!(:ban_2) { create :ban, user: user, moderator: user }

    before { get :index, params: { page: 1, limit: 1 }, format: :json }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(collection).to have(2).items
    end
  end
end
