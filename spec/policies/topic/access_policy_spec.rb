describe Topic::AccessPolicy do
  subject { described_class.allowed? topic, decorated_user }
  let(:decorated_user) do
    is_moderator ?
      user.decorate :
      [user.decorate, nil].sample
  end
  let(:is_moderator) { false }
  before do
    if is_moderator
      allow(decorated_user).to receive(:moderation_staff?).and_return true
    end
  end

  context 'common topic' do
    let(:topic) { build :topic }
    it { is_expected.to eq true }
  end

  context 'topic in premoderation forum' do
    let(:topic) { build :topic, forum_id: Forum::PREMODERATION_ID, user: topic_user }
    let(:topic_user) { user_2 }
    it { is_expected.to eq false }

    context 'topic author' do
      let(:decorated_user) { user.decorate }
      let(:topic_user) { user }
      it { is_expected.to eq true }
    end

    context 'moderator' do
      let(:is_moderator) { true }
      it { is_expected.to eq true }
    end
  end

  context 'club topic' do
    before do
      allow(Club::AccessPolicy)
        .to receive(:allowed?)
        .with(club, decorated_user)
        .and_return is_allowed
    end
    let(:is_allowed) { [true, false].sample }

    let(:club) { build :club }
    let(:club_page) { build :club_page, club: club }

    let(:topic) do
      [
        build(:club_topic, linked: club),
        build(:club_page_topic, linked: club_page),
        build(:club_user_topic, linked: club)
      ].sample
    end

    it { is_expected.to eq is_allowed }

    context 'moderator' do
      let(:is_moderator) { true }
      it { is_expected.to eq true }
    end
  end
end
