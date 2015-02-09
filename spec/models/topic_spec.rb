require 'cancan/matchers'

describe Topic do
  describe 'validations' do
    it { should validate_presence_of :title }
  end

  describe 'callbacks' do
    let(:user) { create :user }
    let(:topic) { create :topic, user: user }

    it 'creation subscribes author to self' do
      expect { topic }.to change(Subscription, :count).by 1
      expect(user.subscribed?(topic)).to be_truthy
    end
  end

  describe 'permissions' do
    let(:topic) { build_stubbed :topic }
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      it { should_not be_able_to :new, topic }
      it { should_not be_able_to :create, topic }
      it { should_not be_able_to :update, topic }
      it { should_not be_able_to :destroy, topic }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user }

      it { should_not be_able_to :new, topic }
      it { should_not be_able_to :create, topic }
      it { should_not be_able_to :update, topic }
      it { should_not be_able_to :destroy, topic }

      context 'topic owner' do
        let(:topic) { build_stubbed :topic, user: user, created_at: created_at }
        let(:created_at) { Time.zone.now }

        it { should be_able_to :new, topic }
        it { should be_able_to :create, topic }
        it { should be_able_to :update, topic }
        it { should be_able_to :destroy, topic }

        context '3 hours ago topic' do
          let(:created_at) { 239.minutes.ago }
          it { should be_able_to :destroy, topic }
        end

        context '4 hours ago topic' do
          let(:created_at) { 241.minutes.ago }
          it { should_not be_able_to :destroy, topic }
        end

        context '2 months ago topic' do
          let(:created_at) { 89.days.ago }
          it { should be_able_to :update, topic }
        end

        context '3 months ago topic' do
          let(:created_at) { 94.days.ago }
          it { should_not be_able_to :update, topic }
        end
      end

      context 'moderator' do
        subject { Ability.new build_stubbed(:user, :moderator) }
        it { should be_able_to :manage, topic }
      end
    end
  end
end
