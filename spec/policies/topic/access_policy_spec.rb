describe Topic::AccessPolicy do
  subject { Topic::AccessPolicy.allowed? topic, decorated_user }
  let(:decorated_user) do
    is_club_member ?
      user.decorate :
      [user.decorate, nil].sample
  end
  let(:is_club_member) { false }
  before do
    allow(Club::AccessPolicy)
      .to receive(:allowed?)
      .with(club, decorated_user)
      .and_return is_allowed
  end
  let(:club) do
    build_stubbed :club,
      is_shadowbanned: is_shadowbanned,
      is_censored: is_censored
  end
  let(:is_shadowbanned) { false }
  let(:is_censored) { false }
  let(:club_page) { build_stubbed :club_page, club: club }

  let(:is_allowed) { [true, false].sample }

  context 'no linked club' do
    let(:topic) { build_stubbed :topic }
    it { is_expected.to eq true }
  end

  context 'linked club' do
    let(:is_shadowbanned) { true }

    context 'Topics::EntryTopics::ClubTopic' do
      let(:topic) { build_stubbed :club_topic, linked: club }
      it { is_expected.to eq is_allowed }
    end

    context 'Topics::EntryTopics::ClubPageTopic' do
      let(:topic) { build_stubbed :club_page_topic, linked: club_page }
      it { is_expected.to eq is_allowed }
    end

    context 'Topics::ClubUserTopic' do
      let(:topic) { build_stubbed :club_user_topic, linked: club }
      it { is_expected.to eq is_allowed }
    end
  end
end
