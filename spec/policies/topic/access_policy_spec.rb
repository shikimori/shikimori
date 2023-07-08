describe Topic::AccessPolicy do
  subject { described_class.allowed? topic, decorated_user }
  let(:decorated_user) { [user.decorate, nil].sample }

  context 'common topic' do
    let(:topic) { build_stubbed :topic }
    it { is_expected.to eq true }
  end

  context 'club topic' do
    before do
      allow(Club::AccessPolicy)
        .to receive(:allowed?)
        .with(club, decorated_user)
        .and_return is_allowed
    end
    let(:is_allowed) { [true, false].sample }

    let(:club) { build_stubbed :club }
    let(:club_page) { build_stubbed :club_page, club: club }

    let(:topic) do
      [
        build_stubbed(:club_topic, linked: club),
        build_stubbed(:club_page_topic, linked: club_page),
        build_stubbed(:club_user_topic, linked: club)
      ].sample
    end

    it { is_expected.to eq is_allowed }

    context 'moderator' do
      let(:comment_user) { user }
      let(:decorated_user) { user.decorate }
      before { allow(decorated_user).to receive(:moderation_staff?).and_return true }

      it { is_expected.to eq true }
    end
  end
end
