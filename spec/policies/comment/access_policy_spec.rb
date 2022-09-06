describe Comment::AccessPolicy do
  subject { Comment::AccessPolicy.allowed? comment, decorated_user }
  let(:comment) { build_stubbed :comment, commentable: topic }
  let(:decorated_user) do
    is_club_member ?
      user.decorate :
      [user.decorate, nil].sample
  end
  let(:is_club_member) { false }
  before do
    allow(decorated_user).to receive(:club_ids).and_return [club.id] if is_club_member
  end
  let(:club) { build_stubbed :club, is_shadowbanned: is_shadowbanned }
  let(:club_page) { build_stubbed :club_page, club: club }

  context 'no linked club' do
    it { is_expected.to eq true }
  end

  context 'linked club' do
    let(:is_shadowbanned) { true }

    context 'Topics::EntryTopics::ClubTopic' do
      let(:topic) { build_stubbed :club_topic, linked: club }

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
      end
    end

    context 'Topics::EntryTopics::ClubPageTopic' do
      let(:topic) { build_stubbed :club_page_topic, linked: club_page }

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
      end
    end

    context 'Topics::ClubUserTopic' do
      let(:topic) { build_stubbed :club_user_topic, linked: club }

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
      end
    end
  end
end
