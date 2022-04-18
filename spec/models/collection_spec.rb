describe Collection do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:links).dependent :destroy }
    it { is_expected.to have_many(:collection_roles).dependent :destroy }
    it { is_expected.to have_many :coauthors }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:text).is_at_most(400000) }
    it { is_expected.to validate_presence_of :kind }
    it { is_expected.to validate_presence_of :locale }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::Collection::Kind.values) }
    # it { is_expected.to enumerize(:state).in(*Types::Collection::State.values) }
    it { is_expected.to enumerize(:locale).in(*Types::Locale.values) }
  end

  describe 'aasm' do
    subject { build :collection, state }

    context 'unpublished' do
      let(:state) { Types::Collection::State[:unpublished] }

      it { is_expected.to have_state state }
      it { is_expected.to allow_transition_to :published }
      it { is_expected.to transition_from(state).to(:published).on_event(:to_published) }
      it { is_expected.to allow_transition_to :private }
      it { is_expected.to transition_from(state).to(:private).on_event(:to_private) }
      it { is_expected.to allow_transition_to :opened }
      it { is_expected.to transition_from(state).to(:opened).on_event(:to_opened) }
    end

    context 'published' do
      let(:state) { Types::Collection::State[:published] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :unpublished }
      it { is_expected.to allow_transition_to :private }
      it { is_expected.to transition_from(state).to(:private).on_event(:to_private) }
      it { is_expected.to allow_transition_to :opened }
      it { is_expected.to transition_from(state).to(:opened).on_event(:to_opened) }
    end

    context 'private' do
      let(:state) { Types::Collection::State[:private] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :unpublished }
      it { is_expected.to allow_transition_to :published }
      it { is_expected.to transition_from(state).to(:published).on_event(:to_published) }
      it { is_expected.to allow_transition_to :opened }
      it { is_expected.to transition_from(state).to(:opened).on_event(:to_opened) }
    end

    context 'opened' do
      let(:state) { Types::Collection::State[:opened] }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :unpublished }
      it { is_expected.to allow_transition_to :published }
      it { is_expected.to transition_from(state).to(:published).on_event(:to_published) }
      it { is_expected.to allow_transition_to :private }
      it { is_expected.to transition_from(state).to(:private).on_event(:to_private) }
    end

    # decribe 'transitions' do
    #   context 'to_published' do
    #     let(:state) do
    #       [
    #         Types::Collection::State[:unpublished],
    #         Types::Collection::State[:private],
    #         Types::Collection::State[:opened]
    #       ].sample
    #     end
    #     include_context :timecop
    #     before { allow(subject).to receive(:fill_published_at).and_call_original }
    #     before { subject.to_published! }
    #     it do
    #       expect(subject).to have_received :fill_published_at
    #       expect(subject.published_at).to be_within(0.1).of Time.zone.now
    #       expect(subject).to be_persisted
    #       expect(subject).to_not be_changed
    #     end
    #   end
    # end
  end

  describe 'instance methods' do
    describe '#collection_role' do
      let(:user) { build_stubbed :user }
      let(:collection) { build_stubbed :collection, collection_roles: [collection_role] }
      let(:collection_role) { build_stubbed :collection_role, user: user }
      subject { collection.collection_role user }

      it { is_expected.to eq collection_role }
    end

    describe '#coauthor?' do
      let(:collection) { build_stubbed :collection }
      let(:user) { build_stubbed :user }
      subject { collection.coauthor? user }

      context 'owner' do
        let(:collection) { build_stubbed :collection, user: user }
        it { is_expected.to be false }
      end

      context 'admin' do
        let(:collection) do
          build_stubbed :collection,
            collection_roles: [build_stubbed(:collection_role, user: user)]
        end
        it { is_expected.to be true }
      end

      context 'not a member' do
        it { is_expected.to be false }
      end
    end
  end

  describe 'permissions' do
    let(:collection) { build_stubbed :collection, :published }
    let(:user) { build_stubbed :user, :user, :week_registered }
    subject { Ability.new user }

    context 'collection owner' do
      let(:collection) { build_stubbed :collection, :published, user: user }

      context 'not banned' do
        it { is_expected.to be_able_to :read, collection }
        it { is_expected.to be_able_to :new, collection }
        it { is_expected.to be_able_to :create, collection }
        it { is_expected.to be_able_to :edit, collection }
        it { is_expected.to be_able_to :update, collection }
        it { is_expected.to be_able_to :destroy, collection }
        it { is_expected.to_not be_able_to :manage, collection }
      end

      context 'newly registered' do
        let(:user) { build_stubbed :user, :user }

        it { is_expected.to be_able_to :read, collection }
        it { is_expected.to_not be_able_to :new, collection }
        it { is_expected.to_not be_able_to :create, collection }
        it { is_expected.to_not be_able_to :edit, collection }
        it { is_expected.to_not be_able_to :update, collection }
        it { is_expected.to_not be_able_to :destroy, collection }
        it { is_expected.to_not be_able_to :manage, collection }
      end

      context 'day registered' do
        let(:user) { build_stubbed :user, :user, :day_registered }

        it { is_expected.to be_able_to :read, collection }
        it { is_expected.to_not be_able_to :new, collection }
        it { is_expected.to_not be_able_to :create, collection }
        it { is_expected.to_not be_able_to :edit, collection }
        it { is_expected.to_not be_able_to :update, collection }
        it { is_expected.to_not be_able_to :destroy, collection }
        it { is_expected.to_not be_able_to :manage, collection }
      end

      context 'banned' do
        let(:user) { build_stubbed :user, :banned }

        it { is_expected.to be_able_to :read, collection }
        it { is_expected.to_not be_able_to :new, collection }
        it { is_expected.to_not be_able_to :create, collection }
        it { is_expected.to_not be_able_to :edit, collection }
        it { is_expected.to_not be_able_to :update, collection }
        it { is_expected.to_not be_able_to :destroy, collection }
        it { is_expected.to_not be_able_to :manage, collection }
      end
    end

    context 'collection_moderator' do
      let(:user) { build_stubbed :user, :collection_moderator }
      it { is_expected.to be_able_to :manage, collection }
    end

    context 'collection coauthor' do
      let(:collection) { create :collection, user: user_2 }
      let(:user) { user_3 }
      let!(:collection_role) do
        create :collection_role, user: user, collection: collection
      end
      it { is_expected.to_not be_able_to :new, collection }
      it { is_expected.to_not be_able_to :create, collection }
      it { is_expected.to be_able_to :edit, collection }
      it { is_expected.to be_able_to :update, collection }
      it { is_expected.to_not be_able_to :destroy, collection }
    end

    context 'user' do
      it { is_expected.to be_able_to :read, collection }
      it { is_expected.to_not be_able_to :new, collection }
      it { is_expected.to_not be_able_to :create, collection }
      it { is_expected.to_not be_able_to :edit, collection }
      it { is_expected.to_not be_able_to :update, collection }
      it { is_expected.to_not be_able_to :destroy, collection }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to be_able_to :read, collection }
      it { is_expected.to_not be_able_to :new, collection }
      it { is_expected.to_not be_able_to :edit, collection }
      it { is_expected.to_not be_able_to :destroy, collection }
    end
  end

  describe 'instance methods' do
    let(:model) { build :collection, id: 1, name: 'тест' }

    describe '#to_param' do
      it { expect(model.to_param).to eq '1-test' }
    end

    describe '#db_type' do
      before { subject.kind = kind }

      context 'anime' do
        let(:kind) { Types::Collection::Kind[:anime] }
        its(:db_type) { is_expected.to eq 'Anime' }
      end

      context 'manga' do
        let(:kind) { Types::Collection::Kind[:manga] }
        its(:db_type) { is_expected.to eq 'Manga' }
      end

      context 'ranobe' do
        let(:kind) { Types::Collection::Kind[:ranobe] }
        its(:db_type) { is_expected.to eq 'Manga' }
      end

      context 'character' do
        let(:kind) { Types::Collection::Kind[:character] }
        its(:db_type) { is_expected.to eq 'Character' }
      end

      context 'person' do
        let(:kind) { Types::Collection::Kind[:person] }
        its(:db_type) { is_expected.to eq 'Person' }
      end
    end

    describe '#topic_user' do
      it { expect(model.topic_user).to eq model.user }
    end
  end

  it_behaves_like :antispam_concern, :collection
  it_behaves_like :clubs_concern, :collection
  it_behaves_like :moderatable_concern, :collection
  it_behaves_like :topics_concern, :collection
end
