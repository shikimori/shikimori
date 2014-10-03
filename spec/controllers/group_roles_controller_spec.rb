require 'spec_helper'

describe GroupRolesController do
  let(:club) { create :group }
  include_context :authenticated

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
end
