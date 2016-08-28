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
