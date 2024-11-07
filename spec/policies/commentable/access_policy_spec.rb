describe Commentable::AccessPolicy do
  subject { described_class.allowed? commentable, current_user }
  let(:current_user) { [nil, user, user.decorate].sample }

  context 'no commentable' do
    let(:commentable) { nil }
    it { is_expected.to eq false }
  end

  context 'user' do
    let(:commentable) { user_2 }
    let(:commentable) do
      build_stubbed :user,
        preferences: build_stubbed(:user_preferences, comments_in_profile: true)
    end

    context 'user with disabled profile comments' do
      before { commentable.preferences.comments_in_profile = false }
      it { is_expected.to eq false }

      context 'moderator' do
        let(:current_user) { [user.decorate, user].sample }
        before { allow(current_user).to receive(:moderation_staff?).and_return true }
        it { is_expected.to eq true }
      end

      context 'own profile' do
        let(:current_user) { commentable }
        it { is_expected.to eq true }
      end
    end

    context 'user with censored_profile' do
      before { commentable.roles = %i[censored_profile] }
      it { is_expected.to eq false }

      context 'moderator' do
        let(:current_user) { [user.decorate, user].sample }
        before { allow(current_user).to receive(:moderation_staff?).and_return true }
        it { is_expected.to eq true }
      end

      context 'own profile' do
        let(:current_user) { commentable }
        it { is_expected.to eq true }
      end
    end
  end

  context 'topic' do
    before do
      allow(Topic::AccessPolicy)
        .to receive(:allowed?)
        .with(commentable, current_user)
        .and_return is_allowed
    end
    let(:commentable) { build_stubbed :topic }
    let(:is_allowed) { [true, false].sample }

    it { is_expected.to eq is_allowed }

    context 'moderator' do
      let(:current_user) { [user.decorate, user].sample }
      before { allow(current_user).to receive(:moderation_staff?).and_return true }
      it { is_expected.to eq true }
    end
  end
end
