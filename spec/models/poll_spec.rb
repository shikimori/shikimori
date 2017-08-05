describe Poll do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :poll_variants }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
  end

  describe 'state_machine' do
    it { is_expected.to have_states :pending, :started, :stopped }

    it { is_expected.to handle_events :start, wnen: :pending }
    it { is_expected.to reject_events :stop, when: :pending }

    # it { is_expected.to reject_events :start, wnen: :started }
    it { is_expected.to handle_events :stop, when: :started }

    it { is_expected.to reject_events :start, :stop, when: :stopped }
  end

  describe 'permissions' do
    let(:poll) { build :poll, poll_state, user: poll_user }
    let(:user) { build_stubbed :user }
    let(:poll_state) { :started }

    subject { Ability.new user }

    context 'poll owner' do
      let(:poll_user) { user }

      context 'pending poll' do
        let(:poll_state) { :pending }

        it { is_expected.to be_able_to :new, poll }
        it { is_expected.to be_able_to :create, poll }
        it { is_expected.to be_able_to :edit, poll }
        it { is_expected.to be_able_to :update, poll }
        it { is_expected.to be_able_to :destroy, poll }
        it { is_expected.to be_able_to :start, poll }
        it { is_expected.to_not be_able_to :stop, poll }
      end

      context 'started poll' do
        let(:poll_state) { :started }

        it { is_expected.to_not be_able_to :new, poll }
        it { is_expected.to_not be_able_to :create, poll }
        it { is_expected.to_not be_able_to :edit, poll }
        it { is_expected.to_not be_able_to :update, poll }
        it { is_expected.to_not be_able_to :destroy, poll }
        it { is_expected.to_not be_able_to :start, poll }
        it { is_expected.to be_able_to :stop, poll }
      end

      context 'stopped poll' do
        let(:poll_state) { :stopped }

        it { is_expected.to_not be_able_to :new, poll }
        it { is_expected.to_not be_able_to :create, poll }
        it { is_expected.to_not be_able_to :edit, poll }
        it { is_expected.to_not be_able_to :update, poll }
        it { is_expected.to_not be_able_to :destroy, poll }
        it { is_expected.to_not be_able_to :start, poll }
        it { is_expected.to_not be_able_to :stop, poll }
      end
    end

    context 'not import owner' do
      let(:poll_user) { build_stubbed :user }

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
