describe GroupRolesController do
  let(:club) { create :group }
  include_context :authenticated, :user

  describe '#create' do
    before { post :create, club_id: club.id, group_role: { group_id: club.id, user_id: user.id } }

    it { should redirect_to club_url(club) }
    it { expect(club.joined? user).to be true }
  end

  describe '#destroy' do
    let!(:group_role) { create :group_role, group: club, user: user }
    before { post :destroy, club_id: club.id, id: group_role.id }

    it { should redirect_to club_url(club) }
    it { expect(club.joined? user).to be false }
  end

  describe '#autocomplete' do
    let(:user) { create :user, nickname: 'Fff' }
    let!(:group_role) { create :group_role, group: club, user: user }
    let(:club) { create :group, owner: user }
    before { get :autocomplete, club_id: club.to_param, search: user.nickname }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    it { expect(collection).to eq [user] }
  end
end
