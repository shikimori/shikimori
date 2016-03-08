require 'cancan/matchers'

describe Topic do
  describe 'validations' do
    it { should validate_presence_of :title }
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
      let(:user) { build_stubbed :user, :user, :day_registered }

      it { should_not be_able_to :new, topic }
      it { should_not be_able_to :create, topic }
      it { should_not be_able_to :update, topic }
      it { should_not be_able_to :destroy, topic }

      context 'topic owner' do
        let(:topic) { build_stubbed :topic, user: user, created_at: created_at }
        let(:created_at) { Time.zone.now }

        context 'day registered' do
          it { should be_able_to :new, topic }
          it { should be_able_to :create, topic }
          it { should be_able_to :update, topic }
          it { should be_able_to :destroy, topic }
        end

        context 'newly registered' do
          let(:user) { build_stubbed :user, :user }
          it { should_not be_able_to :new, topic }
          it { should_not be_able_to :create, topic }
        end

        context '3 hours ago topic' do
          let(:created_at) { 239.minutes.ago }
          it { should be_able_to :destroy, topic }
        end

        context '4 hours ago topic' do
          let(:created_at) { 241.minutes.ago }
          it { should_not be_able_to :destroy, topic }
        end

        context '2 months ago topic' do
          let(:created_at) { 86.days.ago }
          it { should be_able_to :update, topic }
        end

        #context '3 months ago topic' do
          #let(:created_at) { 94.days.ago }
          #it { should_not be_able_to :update, topic }
        #end
      end

      context 'moderator' do
        subject { Ability.new build_stubbed(:user, :moderator) }
        it { should be_able_to :manage, topic }
      end
    end
  end

  describe 'instance methods' do
    let(:topic) { create :topic }

    def create_comment
      create :comment, :with_counter_cache, commentable: topic
    end

    def create_summary
      create :comment, :review, :with_counter_cache, commentable: topic
    end

    describe '#any_comments?' do
      subject { topic.any_comments? }

      context 'with comments' do
        before { create_comment }
        it { is_expected.to eq true }
      end

      context 'with summaries' do
        before { create_summary }
        it { is_expected.to eq true }
      end

      context 'without comments' do
        it { is_expected.to eq false }
      end
    end

    describe '#any_summaries?' do
      subject { topic.any_summaries? }

      context 'with summaries' do
        before { create_summary }
        it { is_expected.to eq true }
      end

      context 'without summaries' do
        before { create_comment }
        it { is_expected.to eq false }
      end
    end

    describe '#all_summaries?' do
      subject { topic.all_summaries? }

      context 'all summaries' do
        before do
          create_summary
          create_summary
        end

        it { is_expected.to eq true }
      end

      context 'not all summaries' do
        before do
          create_comment
          create_summary
          create_summary
        end

        it { is_expected.to eq false }
      end
    end

    describe '#summaries_count' do
      subject { topic.summaries_count }

      before do
        create_comment
        create_summary
        create_summary
      end

      it { is_expected.to eq 2 }
    end
  end
end
