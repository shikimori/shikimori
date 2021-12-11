# frozen_string_literal: true

describe Club::Update do
  subject { described_class.call club, kick_ids, params, page, user }

  let(:club) { create :club, :with_topics, owner: user }
  let(:page) { 'account' }
  let(:kick_ids) { nil }

  context 'valid params' do
    let(:params) { { name: 'test club' } }
    before { subject }

    it do
      expect(club.errors).to be_empty
      expect(club.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }
    before { subject }

    it do
      expect(club.errors).to be_present
      expect(club.reload).not_to have_attributes params
    end
  end

  context 'with kick ids' do
    let!(:club_role) { create :club_role, club: club, user: user }
    let(:kick_ids) { user.id }

    let(:params) { {} }
    before { subject }

    it do
      expect(club.errors).to be_empty
      expect(club.reload.club_roles_count).to eq 0
    end
  end

  context 'with admin ids' do
    let(:user_2) { create :user }
    let(:user_3) { create :user }

    let!(:club_role) { create :club_role, :admin, club: club, user: user }
    let!(:club_role_2) { create :club_role, club: club, user: user_2 }
    let!(:club_role_3) { create :club_role, :admin, club: club, user: user_3 }

    let(:page) { 'members' }
    let(:params) { { admin_ids: [user.id] } }
    before { subject }

    it do
      expect(club.errors).to be_empty
      expect(club.reload.members.to_set).to eq [user, user_2, user_3].to_set
      expect(club.admins).to eq [user]
    end
  end
end
