# frozen_string_literal: true

describe Topic do
  describe 'associations' do
    it { is_expected.to belong_to :forum }
    it { is_expected.to belong_to(:linked).optional }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :messages }
    it { is_expected.to have_many :topic_ignores }
    it { is_expected.to have_many :viewings }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :locale }
    it { is_expected.to validate_presence_of :title }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:locale).in(*Types::Locale.values) }
  end

  describe 'callbacks' do
    let(:user) { build_stubbed :user, :user }

    describe '#check_spam_abuse' do
      before { allow(Users::CheckHacked).to receive(:call).and_return true }
      let!(:topic) { create :topic }

      it do
        expect(Users::CheckHacked)
          .to have_received(:call)
          .with(
            model: topic,
            user: topic.user,
            text: topic.body
          )
      end
    end
  end

  describe 'instance methods' do
    describe '#comment_added' do
      let(:topic) { create :topic }

      it 'updated_at is set to created_at of last comment' do
        first = second = third = nil
        Comment.wo_antispam do
          first = create :comment, commentable: topic, created_at: 2.days.ago, body: 'first'
          second = create :comment, commentable: topic, created_at: 1.day.ago, body: 'second'
          third = create :comment, commentable: topic, created_at: 30.minutes.ago, body: 'third'
        end
        third.destroy
        expect(first.commentable.reload.updated_at.to_i).to eq(second.created_at.to_i)
      end
    end

    describe 'comments selected with viewed flag' do
      subject { topic.comments.with_viewed(another_user).first.viewed? }

      let(:topic) { create :topic }
      let(:comment_user) { create :user }
      let(:another_user) { create :user }
      let!(:comment) { create :comment, commentable: topic, user: comment_user }

      context 'comment not viewed' do
        it { is_expected.to eq false }
      end

      context 'comment viewed' do
        before { create :comment_viewing, user: another_user, viewed: comment }
        it { is_expected.to eq true }
      end
    end

    describe '#decomposed_body' do
      let(:topic) { build :topic }
      it { expect(topic.decomposed_body).to be_kind_of Topics::DecomposedBody }
    end
  end

  describe 'permissions' do
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      let(:topic) { build_stubbed :topic }

      it do
        is_expected.not_to be_able_to :new, topic
        is_expected.not_to be_able_to :create, topic
        is_expected.not_to be_able_to :edit, topic
        is_expected.not_to be_able_to :update, topic
        is_expected.not_to be_able_to :destroy, topic
        is_expected.not_to be_able_to :moderate, topic
      end
    end

    context 'not topic owner' do
      let(:user) { build_stubbed :user, :user, :week_registered }
      let(:topic) { build_stubbed :topic, user: build_stubbed(:user, :user) }

      it do
        is_expected.not_to be_able_to :new, topic
        is_expected.not_to be_able_to :create, topic
        is_expected.not_to be_able_to :edit, topic
        is_expected.not_to be_able_to :update, topic
        is_expected.not_to be_able_to :destroy, topic
        is_expected.not_to be_able_to :moderate, topic
      end
    end

    context 'topic owner' do
      let(:user) { build_stubbed :user, :user, :week_registered }
      let(:topic) { build_stubbed :topic, user: user }

      it do
        is_expected.to be_able_to :new, topic
        is_expected.to be_able_to :create, topic
        is_expected.to be_able_to :edit, topic
        is_expected.to be_able_to :update, topic
        is_expected.not_to be_able_to :moderate, topic
      end

      context 'user is registered < 1 week ago' do
        let(:user) { build_stubbed :user, :user, :day_registered }
        it do
          is_expected.not_to be_able_to :new, topic
          is_expected.not_to be_able_to :create, topic
          is_expected.not_to be_able_to :edit, topic
          is_expected.to_not be_able_to :update, topic
          is_expected.not_to be_able_to :moderate, topic
        end
      end

      context 'banned user' do
        let(:user) { build_stubbed :user, :banned, :week_registered }
        it do
          is_expected.not_to be_able_to :new, topic
          is_expected.not_to be_able_to :create, topic
          is_expected.not_to be_able_to :edit, topic
          is_expected.not_to be_able_to :update, topic
          is_expected.not_to be_able_to :moderate, topic
        end
      end

      describe 'permissions based on topic creation date' do
        let(:topic) { build_stubbed :topic, user: user, created_at: created_at }

        context 'topic created < 1 day ago' do
          let(:created_at) { 1.day.ago + 1.minute }
          it { is_expected.to be_able_to :destroy, topic }
        end

        context 'topic created >= 4 hours ago' do
          let(:created_at) { 1.day.ago - 1.minute }
          it { is_expected.not_to be_able_to :destroy, topic }
        end
      end

      describe 'Topics::ClubUserTopic' do
        let(:club_role) { build_stubbed :club_role, member_role, user: user }
        let(:topic) do
          build_stubbed :club_user_topic,
            created_at: 1.year.ago,
            user: user,
            linked: club,
            comments_count: comments_count
        end
        let(:club) do
          build_stubbed :club,
            topic_policy: topic_policy,
            member_roles: [club_role]
        end
        let(:member_role) { :member }
        let(:topic_policy) { Types::Club::TopicPolicy[:members] }
        let(:comments_count) { 2_000 }

        context 'own topic' do
          it { is_expected.to be_able_to :edit, topic }
          it { is_expected.to be_able_to :update, topic }

          context 'comments_count < 2000' do
            let(:comments_count) { 1_999 }
            it { is_expected.to be_able_to :destroy, topic }
          end

          context 'comments_count >= 2000' do
            it { is_expected.to_not be_able_to :destroy, topic }
          end

          context 'members policy' do
            it { is_expected.to be_able_to :new, topic }
            it { is_expected.to be_able_to :create, topic }
          end

          context 'admins policy' do
            let(:topic_policy) { Types::Club::TopicPolicy[:admins] }

            context 'not admin' do
              it { is_expected.to_not be_able_to :new, topic }
              it { is_expected.to_not be_able_to :create, topic }
            end

            context 'admin' do
              let(:member_role) { :admin }
              it { is_expected.to be_able_to :new, topic }
              it { is_expected.to be_able_to :create, topic }
            end
          end
        end

        context 'other user topic' do
          let(:topic) do
            build_stubbed :club_user_topic,
              user: build_stubbed(:user),
              linked: club
          end

          context 'admin' do
            let(:member_role) { :admin }
            it { is_expected.to be_able_to :edit, topic }
            it { is_expected.to be_able_to :update, topic }
            it { is_expected.to be_able_to :destroy, topic }
          end

          context 'not admin' do
            it { is_expected.to_not be_able_to :edit, topic }
            it { is_expected.to_not be_able_to :update, topic }
            it { is_expected.to_not be_able_to :destroy, topic }
          end
        end
      end
    end

    context 'news_moderator' do
      let(:user) { build_stubbed :user, :news_moderator }
      let(:topic) { build_stubbed :topic }

      context 'common topic' do
        it { is_expected.to_not be_able_to :edit, topic }
        it { is_expected.to_not be_able_to :update, topic }
        it { is_expected.to_not be_able_to :manage, topic }
        it { is_expected.not_to be_able_to :moderate, topic }
      end

      context 'generated topic' do
        let(:topic) { build_stubbed :club_topic }
        it { is_expected.to_not be_able_to :manage, topic }
      end

      context 'generated critique topic' do
        let(:topic) { build_stubbed :critique_topic }
        it { is_expected.to_not be_able_to :manage, topic }
      end

      context 'news topic' do
        let(:topic) { build_stubbed :news_topic }
        it { is_expected.to be_able_to :manage, topic }
      end
    end

    context 'forum_moderator' do
      let(:user) { build_stubbed :user, :forum_moderator }
      let(:topic) do
        build_stubbed :topic,
          user: build_stubbed(:user),
          comments_count: comments_count
      end
      let(:comments_count) { 1999 }

      context 'common topic' do
        context 'comments_count < 2000' do
          it { is_expected.to be_able_to :edit, topic }
          it { is_expected.to be_able_to :update, topic }
          it { is_expected.to be_able_to :manage, topic }
          it { is_expected.not_to be_able_to :moderate, topic }
        end

        context 'comments_count >= 2000' do
          let(:comments_count) { 2000 }
          it { is_expected.to be_able_to :edit, topic }
          it { is_expected.to be_able_to :update, topic }
          it { is_expected.to_not be_able_to :manage, topic }
          it { is_expected.not_to be_able_to :moderate, topic }
        end
      end

      context 'generated topic' do
        let(:topic) { build_stubbed :club_topic, user: build_stubbed(:user) }
        it { is_expected.to_not be_able_to :manage, topic }
      end

      context 'generated critique topic' do
        let(:topic) { build_stubbed :critique_topic, user: build_stubbed(:user) }
        it { is_expected.to be_able_to :manage, topic }
      end
    end

    describe 'club topic' do
      let(:topic) { build_stubbed :club_topic, linked: club }
      let(:club) { build_stubbed :club }

      context 'common user' do
        let(:user) { build_stubbed :user, :user }
        it { is_expected.to_not be_able_to :broadcast, topic }
      end

      context 'club member' do
        let(:user) { build_stubbed :user, :user, club_roles: [club_member_role] }
        let(:club_member_role) { build_stubbed :club_role, :member, club: club }
        it { is_expected.to_not be_able_to :broadcast, topic }
      end

      context 'club admin' do
        let(:user) do
          build_stubbed :user, :user, :week_registered,
            club_admin_roles: [club_admin_role]
        end
        let(:club_admin_role) { build_stubbed :club_role, :admin, club: club }
        it { is_expected.to be_able_to :broadcast, topic }
      end
    end

    describe 'critique topic' do
      let(:topic) { build_stubbed :critique_topic, user: critique_owner }
      let(:user) { build_stubbed :user, :user, :week_registered }

      context 'common user' do
        let(:critique_owner) { build_stubbed :user, :user, :week_registered }

        it { is_expected.to_not be_able_to :new, topic }
        it { is_expected.to_not be_able_to :edit, topic }
        it { is_expected.to_not be_able_to :update, topic }
        it { is_expected.to_not be_able_to :create, topic }
        it { is_expected.to_not be_able_to :update, topic }
        it { is_expected.not_to be_able_to :moderate, topic }
      end

      context 'critique owner' do
        let(:critique_owner) { user }

        it { is_expected.to be_able_to :new, topic }
        it { is_expected.to be_able_to :edit, topic }
        it { is_expected.to be_able_to :update, topic }
        it { is_expected.to be_able_to :create, topic }
        it { is_expected.to be_able_to :update, topic }
        it { is_expected.not_to be_able_to :moderate, topic }
      end
    end

    describe 'collection topic' do
      let(:topic) { build_stubbed :collection_topic, user: collection_owner }
      let(:user) { build_stubbed :user, :user, :week_registered }

      context 'common user' do
        let(:collection_owner) { build_stubbed :user, :user, :week_registered }

        it { is_expected.to_not be_able_to :new, topic }
        it { is_expected.to_not be_able_to :edit, topic }
        it { is_expected.to_not be_able_to :update, topic }
        it { is_expected.to_not be_able_to :create, topic }
        it { is_expected.to_not be_able_to :update, topic }
        it { is_expected.not_to be_able_to :moderate, topic }
      end

      context 'critique owner' do
        let(:collection_owner) { user }

        it { is_expected.to be_able_to :new, topic }
        it { is_expected.to be_able_to :edit, topic }
        it { is_expected.to be_able_to :update, topic }
        it { is_expected.to be_able_to :create, topic }
        it { is_expected.to be_able_to :update, topic }
        it { is_expected.not_to be_able_to :moderate, topic }
      end
    end
  end

  it_behaves_like :antispam_concern, :topic
end
