# frozen_string_literal: true

describe Club::Update do
  subject { Club::Update.call club, kick_ids, params }

  let(:user) { create :user }
  let(:club) { create :club, :with_topics, owner: user }
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
      expect(club.errors).to_not be_empty
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

    let(:params) { { admin_ids: [user.id, user_2.id] } }
    before { subject }

    it do
      expect(club.errors).to be_empty
      expect(club.reload.club_roles_count).to eq 2
      expect(club.reload.admins.to_set).to eq [user, user_2].to_set
    end
  end
end
