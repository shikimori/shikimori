describe Topic do
  describe 'associations' do
    it { is_expected.to belong_to :forum }
    it { is_expected.to belong_to :linked }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :messages }
    it { is_expected.to have_many :topic_ignores }
    it { is_expected.to have_many :views }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :locale }
    it { is_expected.to validate_presence_of :title }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:locale).in :ru, :en }
  end

  describe 'permissions' do
    let(:topic) { build_stubbed :topic }
    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      it { is_expected.not_to be_able_to :new, topic }
      it { is_expected.not_to be_able_to :create, topic }
      it { is_expected.not_to be_able_to :update, topic }
      it { is_expected.not_to be_able_to :destroy, topic }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user, :week_registered }

      it { is_expected.not_to be_able_to :new, topic }
      it { is_expected.not_to be_able_to :create, topic }
      it { is_expected.not_to be_able_to :update, topic }
      it { is_expected.not_to be_able_to :destroy, topic }

      context 'topic owner' do
        let(:topic) { build_stubbed :topic, user: user, created_at: created_at }
        let(:created_at) { Time.zone.now }

        context 'day registered' do
          it { is_expected.to be_able_to :new, topic }
          it { is_expected.to be_able_to :create, topic }
          it { is_expected.to be_able_to :update, topic }
          it { is_expected.to be_able_to :destroy, topic }
        end

        context 'newly registered' do
          let(:user) { build_stubbed :user, :user }
          it { is_expected.not_to be_able_to :new, topic }
          it { is_expected.not_to be_able_to :create, topic }
        end

        context '3 hours ago topic' do
          let(:created_at) { 239.minutes.ago }
          it { is_expected.to be_able_to :destroy, topic }
        end

        context '4 hours ago topic' do
          let(:created_at) { 241.minutes.ago }
          it { is_expected.not_to be_able_to :destroy, topic }
        end

        context '2 months ago topic' do
          let(:created_at) { 86.days.ago }
          it { is_expected.to be_able_to :update, topic }
        end

        #context '3 months ago topic' do
          #let(:created_at) { 94.days.ago }
          #it { is_expected.not_to be_able_to :update, topic }
        #end
      end

      context 'moderator' do
        subject { Ability.new build_stubbed(:user, :moderator) }
        it { is_expected.to be_able_to :manage, topic }
      end
    end
  end

  context 'permissions' do
    let(:user) { build_stubbed :user, :user, :week_registered }
    let(:entry) { build_stubbed :entry, user: entry_user, created_at: created_at }

    let(:entry_user) { user }
    let(:created_at) { Time.zone.now }

    subject { Ability.new user }

    context 'entry owner' do
      context 'not banned' do
        it { is_expected.to be_able_to :new, entry }
        it { is_expected.to be_able_to :create, entry }
        it { is_expected.to be_able_to :update, entry }

        context 'old entry' do
          let(:created_at) { 4.hours.ago - 1.minute }
          it { is_expected.to_not be_able_to :destroy, entry }
        end

        context 'new entry' do
          let(:created_at) { 4.hours.ago + 1.minute }
          it { is_expected.to be_able_to :destroy, entry }
        end
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user, created_at: 23.hours.ago }

        it { is_expected.to_not be_able_to :new, entry }
        it { is_expected.to_not be_able_to :create, entry }
        it { is_expected.to be_able_to :update, entry }
        it { is_expected.to_not be_able_to :destroy, entry }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned, :day_registered }

        it { is_expected.to_not be_able_to :new, entry }
        it { is_expected.to_not be_able_to :create, entry }
        it { is_expected.to_not be_able_to :update, entry }
        it { is_expected.to_not be_able_to :destroy, entry }
      end
    end

    context 'forum moderator' do
      let(:user) { build_stubbed :user, :moderator }

      context 'common topic' do
        it { is_expected.to be_able_to :manage, entry }
      end

      context 'generated topic' do
        let(:entry) { build_stubbed :club_topic, user: entry_user, created_at: created_at }
        it { is_expected.to_not be_able_to :manage, entry }
      end

      context 'generated review topic' do
        let(:entry) { build_stubbed :review_topic, user: entry_user, created_at: created_at }
        it { is_expected.to be_able_to :manage, entry }
      end
    end

    context 'user' do
      let(:entry_user) { build_stubbed :user, :week_registered }

      it { is_expected.to_not be_able_to :new, entry }
      it { is_expected.to_not be_able_to :create, entry }
      it { is_expected.to_not be_able_to :update, entry }
      it { is_expected.to_not be_able_to :destroy, entry }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to_not be_able_to :new, entry }
      it { is_expected.to_not be_able_to :create, entry }
      it { is_expected.to_not be_able_to :update, entry }
      it { is_expected.to_not be_able_to :destroy, entry }
    end
  end

end
