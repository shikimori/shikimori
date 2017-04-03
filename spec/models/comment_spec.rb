describe Comment do
  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :commentable }
    it { is_expected.to belong_to :topic }
    it { is_expected.to have_many :messages }
    it { is_expected.to have_many :viewings }
    it { is_expected.to have_many :abuse_requests }
    it { is_expected.to have_many :bans }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :commentable }
    it do
      is_expected
        .to validate_inclusion_of(:commentable_type)
        .in_array Types::Comment::CommentableType.values
    end
  end

  describe 'callbacks' do
    let(:user) { build_stubbed :user }
    let(:user2) { build_stubbed :user }
    let(:topic) { build_stubbed :topic, user: user }
    let(:comment) { create :comment, user: user, commentable: topic }

    describe '#clean' do
      let(:comment) { build :comment }
      after { comment.save }
      it { expect(comment).to receive :clean }
    end

    describe '#forbid_tag_change' do
      let(:comment) { build :comment }
      after { comment.save }
      it { expect(comment).to receive :forbid_tag_change }
    end

    describe '#check_access' do
      let(:comment) { build :comment }
      after { comment.save }
      it { expect(comment).to receive :check_access }
    end

    describe '#cancel_summary' do
      let(:comment) { build :comment, :summary, body: body }
      before { comment.save }

      context 'long comment' do
        let(:body) { 'x' * Comment::MIN_SUMMARY_SIZE }
        it { expect(comment).to be_summary }
      end

      context 'short comment' do
        let(:body) { 'x' * (Comment::MIN_SUMMARY_SIZE - 1) }
        it { expect(comment).to_not be_summary }
      end
    end

    describe '#increment_comments' do
      let(:comment) { build :comment }
      after { comment.save }
      it { expect(comment).to receive :increment_comments }
    end

    describe '#creation_callbacks' do
      let(:comment) { build :comment }
      after { comment.save }
      it { expect(comment).to receive :creation_callbacks }
    end

    # describe '#notify_quoted' do
      # describe 'after_save' do
        # context 'body changed' do
          # let(:comment) { build :comment }
          # after { comment.save }
          # it { expect(comment).to receive :notify_quoted }
        # end

        # context 'body not changed' do
          # let(:comment) { create :comment }
          # after { comment.update is_offtopic: true }
          # it { expect(comment).to_not receive :notify_quoted }
        # end
      # end

      # describe 'after_destroy' do
        # let(:comment) { create :comment }
        # after { comment.destroy }
        # it { expect(comment).to receive :notify_quoted }
      # end
    # end

    describe '#decrement_comments' do
      let(:comment) { create :comment }
      after { comment.destroy }
      it { expect(comment).to receive :decrement_comments }
    end

    describe '#destruction_callbacks' do
      let(:comment) { create :comment }
      after { comment.destroy }
      it { expect(comment).to receive :destruction_callbacks }
    end

    describe '#release_the_banhammer!' do
      let(:comment) { build :comment, :with_banhammer }
      after { comment.save }
      it { expect(Banhammer.instance).to receive :release! }
    end

    describe '#touch_commentable' do
      include_context :timecop

      let(:topic) { create :topic }
      let(:comment) { build :comment, :with_touch_commentable, topic: topic }

      context 'create' do
        subject! { comment.save! }

        context 'commentable with commented_at' do
          it { expect(topic.commented_at).to eq Time.zone.now }
        end

        context 'commentable without updated_at' do
          let(:comment) { build :comment, :with_touch_commentable, commentable: user }
          let(:user) { create :user, updated_at: 1.day.ago }
          it { expect(topic.updated_at).to eq Time.zone.now }
        end
      end

      context 'update' do
        before { comment.save! }
        before { topic.update commented_at: nil }
        subject! { comment.update! body: 'zxcvbn' }

        it { expect(topic.commented_at).to eq Time.zone.now }
      end

      context 'destroy' do
        before { comment.save! }
        before { topic.update commented_at: nil }
        subject! { comment.destroy! }

        it { expect(topic.commented_at).to eq Time.zone.now }
      end
    end

    describe '#remove_replies' do
      let(:comment) { create :comment }
      after { comment.destroy }
      it { expect(comment).to receive :remove_replies }
    end
  end

  describe 'instance methods' do
    let(:user) { build_stubbed :user }
    let(:user2) { build_stubbed :user }
    let(:topic) { build_stubbed :topic, user: user }
    let(:comment) { create :comment, user: user, commentable: topic }

    describe '#html_body' do
      let(:comment) { build :comment, body: body }
      let(:body) { '[b]bold[/b]' }

      it { expect(comment.html_body).to eq '<strong>bold</strong>' }

      describe 'comment in offtopic topic' do
        let(:offtopic_topic) { seed :offtopic_topic }
        let(:comment) do
          create :comment, body: body, commentable: offtopic_topic
        end

        describe 'poster' do
          let(:body) { '[poster]http:///test.com[/poster]' }
          it { expect(comment.html_body).to_not include 'b-poster' }
        end

        describe 'img' do
          let(:body) { '[img w=747 h=1047]http:///test.com[/img]' }
          it { expect(comment.html_body).to_not include 'width=' }
          it { expect(comment.html_body).to_not include 'height=' }
        end

        describe 'image' do
          let(:body) { '[image=149374 9999x9999]' }
          it { expect(comment.html_body).to eq '[image=149374]' }
        end
      end
    end

    # describe '#notify_quoted' do
      # before { allow(Comments::NotifyQuoted).to receive :call }
      # let!(:comment) { create :comment }
      # it { expect(Comments::NotifyQuoted).to have_received(:call).with comment }
    # end

    describe '#forbid_tag_change' do
      let(:comment) { build :comment, body: body }
      subject! { comment.valid? }

      context 'no forbidden tags' do
        let(:body) { 'zxc' }
        it { expect(comment).to be_valid }
      end

      context '[ban]' do
        let(:body) { '[ban=1]' }
        it do
          expect(comment).to_not be_valid
          expect(comment.errors.messages[:base].first).to eq I18n.t('activerecord.errors.models.comments.not_a_moderator')
        end
      end

      context '[broadcast]' do
        let(:body) { '[broadcast]' }
        it do
          expect(comment).to_not be_valid
          expect(comment.errors.messages[:base].first).to eq I18n.t('activerecord.errors.models.comments.not_a_moderator')
        end
      end
    end

    describe '#allowed_summary?' do
      let(:comment) { build :comment, commentable: commentable }

      context 'Topic commentable' do
        let(:commentable) { build :topic }
        it { expect(comment).to_not be_allowed_summary }
      end

      context 'Topics::EntryTopics::AnimeTopic commentable' do
        let(:commentable) { build :anime_topic }
        it { expect(comment).to be_allowed_summary }
      end

      context 'Topics::EntryTopics::MangaTopic commentable' do
        let(:commentable) { build :manga_topic }
        it { expect(comment).to be_allowed_summary }
      end
    end

    describe '#mark_offtopic' do
      let!(:comment) { create :comment, is_offtopic: offtopic }
      let!(:inner_comment) do
        create :comment,
          body: "[comment=#{comment.id}]",
          is_offtopic: offtopic
      end

      before { comment.mark_offtopic flag }

      context 'mark offtopic' do
        let(:offtopic) { false }
        let(:flag) { true }

        it { expect(comment.reload).to be_offtopic }
        it { expect(inner_comment.reload).to be_offtopic }
      end

      context 'mark not offtopic' do
        let(:offtopic) { true }
        let(:flag) { false }

        it { expect(comment.reload).to_not be_offtopic }
        it { expect(inner_comment.reload).to be_offtopic }
      end
    end

    describe '#mark_summary' do
      let!(:comment) { create :comment, is_summary: is_summary }
      before { comment.mark_summary flag }

      context 'mark summary' do
        let(:is_summary) { false }
        let(:flag) { true }

        it { expect(comment.reload).to be_summary }
      end

      context 'mark not summary' do
        let(:is_summary) { true }
        let(:flag) { false }

        it { expect(comment.reload).to_not be_summary }
      end
    end
  end

  describe 'permissions' do
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      let(:comment) { build_stubbed :comment }

      it { is_expected.to_not be_able_to :new, comment }
      it { is_expected.to_not be_able_to :create, comment }
      it { is_expected.to_not be_able_to :update, comment }
      it { is_expected.to_not be_able_to :destroy, comment }
    end

    context 'not comment owner' do
      let(:user) { build_stubbed :user, :user, :day_registered }
      let(:user_2) { build_stubbed :user, :user }
      let(:comment) { build_stubbed :comment, user: user_2 }

      it { is_expected.to_not be_able_to :new, comment }
      it { is_expected.to_not be_able_to :create, comment }
      it { is_expected.to_not be_able_to :update, comment }
      it { is_expected.to_not be_able_to :destroy, comment }

      context 'comment in own profile' do
        let(:comment) do
          build_stubbed :comment,
            user: user_2,
            commentable: user,
            created_at: 1.week.ago
        end

        it { is_expected.to_not be_able_to :update, comment }
        it { is_expected.to be_able_to :destroy, comment }
      end
    end

    context 'comment owner' do
      let(:user) { build_stubbed :user, :user, :day_registered }
      let(:comment) { build_stubbed :comment, user: user }

      it { is_expected.to be_able_to :new, comment }
      it { is_expected.to be_able_to :create, comment }
      it { is_expected.to be_able_to :update, comment }

      context 'user is registered < 1 day ago' do
        let(:user) { build_stubbed :user, :user }

        it { is_expected.to_not be_able_to :new, comment }
        it { is_expected.to_not be_able_to :create, comment }
        it { is_expected.to_not be_able_to :update, comment }

        context 'comment in own profile' do
          let(:comment) { build_stubbed :comment, user: user, commentable: user }

          it { is_expected.to be_able_to :update, comment }
          it { is_expected.to be_able_to :destroy, comment }
        end
      end

      context 'banned user' do
        let(:user) { build_stubbed :user, :banned, :day_registered }

        it { is_expected.to_not be_able_to :new, comment }
        it { is_expected.to_not be_able_to :create, comment }
        it { is_expected.to_not be_able_to :update, comment }
      end

      describe 'permissions based on comment creation date' do
        let(:comment) { build_stubbed :comment, user: user, created_at: created_at }

        context 'comment created < 1.day hours ago' do
          let(:created_at) { 1.day.ago + 1.minute }
          it { is_expected.to be_able_to :destroy, comment }
        end

        context 'comment created >= 1.day hours ago' do
          let(:created_at) { 1.day.ago - 1.minute }
          it { is_expected.to_not be_able_to :destroy, comment }
        end
      end
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :moderator }
      let(:comment) { build_stubbed :comment, user: build_stubbed(:user) }
      it { is_expected.to be_able_to :manage, comment }
    end

    describe 'club comment' do
      let(:comment) do
        build_stubbed :comment,
          user: comment_owner,
          commentable: club_topic,
          created_at: 1.month.ago
      end
      let(:comment_owner) { build_stubbed :user }
      let(:club_topic) { build_stubbed :club_topic, linked: club }
      let(:club) { build_stubbed :club }

      context 'common user' do
        let(:user) { build_stubbed :user, :user }
        it { is_expected.to_not be_able_to :update, comment }
        it { is_expected.to_not be_able_to :destroy, comment }
        it { is_expected.to_not be_able_to :broadcast, comment }
      end

      context 'club member' do
        let(:user) { build_stubbed :user, :user, club_roles: [club_member_role] }
        let(:club_member_role) { build_stubbed :club_role, :member, club: club }

        it { is_expected.to_not be_able_to :destroy, comment }
        it { is_expected.to_not be_able_to :broadcast, comment }
        it { is_expected.to_not be_able_to :update, comment }
      end

      context 'club admin' do
        let(:user) { build_stubbed :user, :user, club_admin_roles: [club_admin_role] }
        let(:club_admin_role) { build_stubbed :club_role, :admin, club: club }

        it { is_expected.to be_able_to :destroy, comment }
        it { is_expected.to be_able_to :broadcast, comment }

        context "another user's comment" do
          it { is_expected.to_not be_able_to :update, comment }
        end

        context 'own comment' do
          let(:comment_owner) { user }
          it { is_expected.to be_able_to :update, comment }
        end
      end
    end
  end
end
