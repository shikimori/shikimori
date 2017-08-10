describe Poll do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:poll_variants).dependent :destroy }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
  end

  describe 'state_machine' do
    it { is_expected.to have_states :pending, :started, :stopped }

    # context 'persisted, with variants' do
      # it { is_expected.to handle_events :start, wnen: :pending }
    # end
    it { is_expected.to reject_events :stop, when: :pending }

    # it { is_expected.to reject_events :start, wnen: :started }
    it { is_expected.to handle_events :stop, when: :started }

    it { is_expected.to reject_events :start, :stop, when: :stopped }
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
      let(:poll) { build_stubbed :poll, state }

      context 'pending' do
        let(:state) { :pending }
        it { expect(poll.bb_code).to be_nil }
      end

      context 'started, stopped' do
        let(:state) { %i[started stopped].sample }
        it { expect(poll.bb_code).to eq "[poll=#{poll.id}]" }
      end
    end
  end

  describe 'permissions' do
    let(:poll) do
      build_stubbed :poll, poll_state,
        user: poll_user,
        poll_variants: poll_variants
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

        it { is_expected.to_not be_able_to :edit, poll }
        it { is_expected.to_not be_able_to :update, poll }
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

    context 'not import owner' do
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
