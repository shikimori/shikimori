describe Article do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :body }
    it { is_expected.to validate_length_of(:body).is_at_most(140000) }
    it { is_expected.to validate_presence_of :locale }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:locale).in(*Types::Locale.values) }
    it { is_expected.to enumerize(:state).in(*Types::Article::State.values) }
  end

  describe 'permissions' do
    let(:article) { build_stubbed :article }
    let(:user) { build_stubbed :user, :user, :week_registered }
    subject { Ability.new user }

    context 'article owner' do
      let(:article) { build_stubbed :article, user: user }

      context 'not banned' do
        it { is_expected.to be_able_to :read, article }
        it { is_expected.to be_able_to :new, article }
        it { is_expected.to be_able_to :create, article }
        it { is_expected.to be_able_to :edit, article }
        it { is_expected.to be_able_to :update, article }
        it { is_expected.to be_able_to :destroy, article }
        it { is_expected.to_not be_able_to :manage, article }
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }

        it { is_expected.to be_able_to :read, article }
        it { is_expected.to_not be_able_to :new, article }
        it { is_expected.to_not be_able_to :create, article }
        it { is_expected.to_not be_able_to :edit, article }
        it { is_expected.to_not be_able_to :update, article }
        it { is_expected.to_not be_able_to :destroy, article }
        it { is_expected.to_not be_able_to :manage, article }
      end

      context 'day registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }

        it { is_expected.to be_able_to :read, article }
        it { is_expected.to_not be_able_to :new, article }
        it { is_expected.to_not be_able_to :create, article }
        it { is_expected.to_not be_able_to :edit, article }
        it { is_expected.to_not be_able_to :update, article }
        it { is_expected.to_not be_able_to :destroy, article }
        it { is_expected.to_not be_able_to :manage, article }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned }

        it { is_expected.to be_able_to :read, article }
        it { is_expected.to_not be_able_to :new, article }
        it { is_expected.to_not be_able_to :create, article }
        it { is_expected.to_not be_able_to :edit, article }
        it { is_expected.to_not be_able_to :update, article }
        it { is_expected.to_not be_able_to :destroy, article }
        it { is_expected.to_not be_able_to :manage, article }
      end
    end

    context 'article_moderator' do
      let(:user) { build_stubbed :user, :article_moderator }
      it { is_expected.to be_able_to :manage, article }
    end

    context 'user' do
      it { is_expected.to be_able_to :read, article }
      it { is_expected.to_not be_able_to :new, article }
      it { is_expected.to_not be_able_to :edit, article }
      it { is_expected.to_not be_able_to :destroy, article }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to be_able_to :read, article }
      it { is_expected.to_not be_able_to :new, article }
      it { is_expected.to_not be_able_to :edit, article }
      it { is_expected.to_not be_able_to :destroy, article }
    end
  end

  describe 'instance methods' do
    let(:model) { build :article, id: 1, name: 'тест' }

    describe '#to_param' do
      it { expect(model.to_param).to eq '1-test' }
    end

    describe '#topic_user' do
      it { expect(model.topic_user).to eq model.user }
    end
  end

  it_behaves_like :antispam_concern, :article
  it_behaves_like :topics_concern, :article
  it_behaves_like :moderatable_concern, :article
end
