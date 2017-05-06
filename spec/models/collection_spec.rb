describe Collection do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:links).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :locale }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::Collection::Kind.values) }
    it { is_expected.to enumerize(:state).in(*Types::Collection::State.values) }
    it { is_expected.to enumerize(:locale).in(*Types::Locale.values) }
  end

  describe 'permissions' do
    let(:collection) { build_stubbed :collection, user: user }
    subject { Ability.new user }
    let(:registration_trait) { :week_registered }

    context 'owner' do
      context 'week_registered' do
        let(:user) { build_stubbed :user, :user, :week_registered }
        it { is_expected.to be_able_to :manage, collection }
      end

      context 'day_registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }
        it { is_expected.to_not be_able_to :manage, collection }
      end
    end

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to_not be_able_to :manage, collection }
      it { is_expected.to be_able_to :read, collection }
    end

    context 'user' do
      let(:user) { build_stubbed :user, :week_registered }
      let(:user_2) { build_stubbed :user, :week_registered }
      let(:collection) { build_stubbed :collection, user: user_2 }
      it { is_expected.to_not be_able_to :manage, collection }
      it { is_expected.to be_able_to :read, collection }
    end
  end

  describe 'instance methods' do
    let(:model) { build :collection, id: 1, name: 'тест' }

    describe '#to_param' do
      it { expect(model.to_param).to eq '1-test' }
    end

    describe '#topic_user' do
      it { expect(model.topic_user).to eq model.user }
    end
  end
end
