# frozen_string_literal: true

describe Topic do
  describe 'associations' do
    it do
      is_expected.to belong_to :forum
      is_expected.to belong_to :linked
      is_expected.to belong_to :user
      is_expected.to have_many :messages
      is_expected.to have_many :topic_ignores
      is_expected.to have_many :viewings
    end
  end

  describe 'validations' do
    it do
      is_expected.to validate_presence_of :locale
      is_expected.to validate_presence_of :title
    end
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:locale).in :ru, :en }
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

    describe '#original_body & #appended_body' do
      let(:topic) { build :topic, body: body, generated: is_generated }
      let(:body) { 'test[wall][/wall]' }

      context 'not generated topic' do
        let(:is_generated) { false }

        context 'with wall' do
          it { expect(topic.original_body).to eq 'test' }
          it { expect(topic.appended_body).to eq '[wall][/wall]' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(topic.original_body).to eq 'test' }
          it { expect(topic.appended_body).to eq '' }
        end
      end

      context 'generated topic' do
        let(:is_generated) { true }

        context 'with wall' do
          it { expect(topic.original_body).to eq 'test[wall][/wall]' }
          it { expect(topic.appended_body).to eq '' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(topic.original_body).to eq 'test' }
          it { expect(topic.appended_body).to eq '' }
        end
      end
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
        is_expected.not_to be_able_to :update, topic
        is_expected.not_to be_able_to :destroy, topic
      end
    end

    context 'not topic owner' do
      let(:user) { build_stubbed :user, :user, :week_registered }
      let(:topic) { build_stubbed :topic, user: build_stubbed(:user) }

      it do
        is_expected.not_to be_able_to :new, topic
        is_expected.not_to be_able_to :create, topic
        is_expected.not_to be_able_to :update, topic
        is_expected.not_to be_able_to :destroy, topic
      end
    end

    context 'topic owner' do
      let(:user) { build_stubbed :user, :user, :week_registered }
      let(:topic) { build_stubbed :topic, user: user }

      it do
        is_expected.to be_able_to :new, topic
        is_expected.to be_able_to :create, topic
        is_expected.to be_able_to :update, topic
      end

      context 'user is registered < 1 week ago' do
        let(:user) { build_stubbed :user, :user, :day_registered }
        it do
          is_expected.not_to be_able_to :new, topic
          is_expected.not_to be_able_to :create, topic
          is_expected.to be_able_to :update, topic
        end
      end

      context 'banned user' do
        let(:user) { build_stubbed :user, :banned, :week_registered }
        it do
          is_expected.not_to be_able_to :new, topic
          is_expected.not_to be_able_to :create, topic
          is_expected.not_to be_able_to :update, topic
        end
      end

      describe 'permissions based on topic creation date' do
        let(:topic) { build_stubbed :topic, user: user, created_at: created_at }

        context 'topic created < 4 hours ago' do
          let(:created_at) { 4.hours.ago + 1.minute }
          it { is_expected.to be_able_to :destroy, topic }
        end

        context 'topic created >= 4 hours ago' do
          let(:created_at) { 4.hours.ago - 1.minute }
          it { is_expected.not_to be_able_to :destroy, topic }
        end
      end
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :moderator }
      let(:topic) { build_stubbed :topic, user: build_stubbed(:user) }

      context 'common topic' do
        it { is_expected.to be_able_to :manage, topic }
      end

      context 'generated topic' do
        let(:topic) { build_stubbed :club_topic, user: build_stubbed(:user) }
        it { is_expected.to_not be_able_to :manage, topic }
      end

      context 'generated review topic' do
        let(:topic) { build_stubbed :review_topic, user: build_stubbed(:user) }
        it { is_expected.to be_able_to :manage, topic }
      end
    end
  end
end
