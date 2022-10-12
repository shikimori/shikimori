describe Club::AccessPolicy do
  subject { described_class.allowed? club, decorated_user }

  let(:club) do
    build_stubbed :club,
      is_shadowbanned: is_shadowbanned,
      is_private: is_private,
      is_censored: is_censored
  end
  let(:decorated_user) do
    is_club_member ?
      user.decorate :
      [user.decorate, nil].sample
  end
  let(:is_club_member) { false }
  before do
    allow(decorated_user).to receive(:club_ids).and_return [club.id] if is_club_member
  end
  let(:is_shadowbanned) { false }
  let(:is_private) { false }
  let(:is_censored) { false }

  describe 'shadowbanned check' do
    let(:is_shadowbanned) { true }

    context 'club member' do
      let(:is_club_member) { true }
      it { is_expected.to eq true }
    end

    context 'not club member' do
      it { is_expected.to eq false }

      context 'not shadowbanned' do
        let(:is_shadowbanned) { false }
        it { is_expected.to eq true }
      end

      context 'moderator' do
        let(:decorated_user) { user.decorate }
        before { allow(decorated_user).to receive(:moderation_staff?).and_return true }
        it { is_expected.to eq true }
      end
    end
  end

  describe 'private check' do
    let(:is_private) { true }

    context 'club member' do
      let(:is_club_member) { true }
      it { is_expected.to eq true }
    end

    context 'not club member' do
      it { is_expected.to eq false }

      context 'not private' do
        let(:is_private) { false }
        it { is_expected.to eq true }
      end
    end
  end

  describe 'censored check' do
    let(:is_censored) { true }
    let(:decorated_user) { nil }

    context 'censored' do
      let(:is_censored) { true }

      context 'guest' do
        it { is_expected.to eq false }
      end

      context 'user' do
        let(:decorated_user) { user.decorate }
        it { is_expected.to eq true }
      end
    end

    context 'not censored' do
      let(:is_censored) { false }
      it { is_expected.to eq true }
    end
  end
end
