describe Poll do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:variants).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:text).is_at_most(10000) }
  end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:width)
        .in(*Types::Poll::Width.values)
    end
  end

  describe 'aasm' do
    it { is_expected.to have_states :pending, :started, :stopped }
    # context 'persisted, with variants' do
      # it { is_expected.to allow_event :start, wnen: :pending }
    # end
    it { is_expected.to_not allow_event :stop, on: :pending }
    # it { is_expected.to_not allow_event :start, wnen: :started }
    it { is_expected.to allow_event :stop, on: :started }
    it { is_expected.to_not allow_event :start, :stop, on: :stopped }
  end

  describe 'instance methods' do
    describe '#name' do
      let(:poll) { build_stubbed :poll, name: name }

      context 'with name' do
        let(:name) { 'Test' }
        it { expect(poll.name).to eq 'Test' }
      end

      context 'without name' do
        let(:name) { '' }
        it { expect(poll.name).to eq "Опрос ##{poll.id}" }
      end
    end

    describe '#bb_code' do
      let(:poll) { build_stubbed :poll }
      it { expect(poll.bb_code).to eq "[poll=#{poll.id}]" }
    end

    describe '#text_html' do
      let(:poll) { build_stubbed :poll, text: '[i]test[/i]' }
      it { expect(poll.text_html).to eq '<em>test</em>' }
    end
  end

  describe 'permissions' do
    let(:poll) do
      build_stubbed :poll, poll_state,
        user: poll_user,
        variants: poll_variants
    end
    let(:poll_variants) { [] }
    let(:user) { build_stubbed :user }
    let(:poll_state) { :started }

    subject { Ability.new user }

    context 'poll owner' do
      let(:poll_user) { user }
      let(:poll_variants) { [build(:poll_variant), build(:poll_variant)] }

      it { is_expected.to be_able_to :show, poll }
      it { is_expected.to be_able_to :new, poll }
      it { is_expected.to be_able_to :create, poll }

      context 'pending poll' do
        let(:poll_state) { :pending }

        it { is_expected.to be_able_to :edit, poll }
        it { is_expected.to be_able_to :update, poll }
        it { is_expected.to be_able_to :destroy, poll }
        it { is_expected.to be_able_to :start, poll }
        it { is_expected.to_not be_able_to :stop, poll }
      end

      context 'started poll' do
        let(:poll_state) { :started }

        it { is_expected.to be_able_to :edit, poll }
        it { is_expected.to be_able_to :update, poll }
        it { is_expected.to_not be_able_to :destroy, poll }
        it { is_expected.to_not be_able_to :start, poll }
        it { is_expected.to be_able_to :stop, poll }
      end

      context 'stopped poll' do
        let(:poll_state) { :stopped }

        it { is_expected.to_not be_able_to :edit, poll }
        it { is_expected.to_not be_able_to :update, poll }
        it { is_expected.to_not be_able_to :destroy, poll }
        it { is_expected.to_not be_able_to :start, poll }
        it { is_expected.to_not be_able_to :stop, poll }
      end
    end

    context 'not poll owner' do
      let(:poll_user) { build_stubbed :user }

      it { is_expected.to_not be_able_to :show, poll }
      it { is_expected.to_not be_able_to :new, poll }
      it { is_expected.to_not be_able_to :create, poll }
      it { is_expected.to_not be_able_to :edite, poll }
      it { is_expected.to_not be_able_to :update, poll }
      it { is_expected.to_not be_able_to :destroy, poll }
      it { is_expected.to_not be_able_to :start, poll }
      it { is_expected.to_not be_able_to :stop, poll }
    end
  end
end
