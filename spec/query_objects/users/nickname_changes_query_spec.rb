describe Users::NicknameChangesQuery do
  subject { described_class.call user, is_moderator }

  let!(:change_1) { create :user_nickname_change, user: user, value: user.nickname }
  let!(:change_2) { create :user_nickname_change, user: user }
  let!(:change_3) { create :user_nickname_change, user: user, is_deleted: true }

  context 'not moderator' do
    let(:is_moderator) { false }
    it { is_expected.to eq [change_2] }
  end

  context 'not moderator' do
    let(:is_moderator) { true }
    it { is_expected.to eq [change_3, change_2] }
  end
end
