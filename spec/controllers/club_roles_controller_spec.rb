describe ClubRolesController do
  let(:club) { create :club }
  include_context :authenticated, :user

  describe '#create' do
    before { post :create, club_id: club.id, club_role: { club_id: club.id, user_id: user.id } }

    it do
      expect(club.joined? user).to be true
      expect(response).to redirect_to club_url(club)
    end
  end

  describe '#destroy' do
    let!(:club_role) { create :club_role, club: club, user: user }
    before { post :destroy, club_id: club.id, id: club_role.id }

    it do
      expect(club.joined? user).to be false
      expect(response).to redirect_to club_url(club)
    end
  end

  describe '#autocomplete' do
    let(:user) { create :user, nickname: 'Fff' }
    let!(:club_role) { create :club_role, club: club, user: user }
    let(:club) { create :club, owner: user }
    before { get :autocomplete, club_id: club.to_param, search: user.nickname }

    it do
      expect(collection).to eq [user]
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'application/json'
    end
  end
end
