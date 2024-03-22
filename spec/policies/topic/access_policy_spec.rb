describe Topic::AccessPolicy do
  subject { described_class.allowed? topic, user }
  let(:user) { [seed(:user), nil].sample }

  context 'common topic' do
    let(:topic) { build :topic }
    it { is_expected.to eq true }
  end

  context 'topic in premoderation or hidden forum' do
    let(:topic) { build :topic, forum_id:, user: topic_user }
    let(:forum_id) { [Forum::PREMODERATION_ID, Forum::HIDDEN_ID].sample }
    let(:topic_user) { user_2 }

    it { is_expected.to eq false }

    context 'topic author' do
      let(:topic_user) { user }
      it { is_expected.to eq true }
    end

    context 'moderator' do
      let(:user) do
        build :user,
          roles: [(User::MODERATION_STAFF_ROLES + %w[news_moderator]).sample]
      end
      it { is_expected.to eq true }
    end
  end

  context 'club topic' do
    before do
      allow(Club::AccessPolicy)
        .to receive(:allowed?)
        .with(club, user)
        .and_return is_allowed
    end
    let(:is_allowed) { [true, false].sample }

    let(:club) { build :club }
    let(:club_page) { build :club_page, club: }

    let(:topic) do
      [
        build(:club_topic, linked: club),
        build(:club_page_topic, linked: club_page),
        build(:club_user_topic, linked: club)
      ].sample
    end

    it { is_expected.to eq is_allowed }
  end
end
