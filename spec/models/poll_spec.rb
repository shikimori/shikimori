describe Poll do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
  end

  describe 'state_machine' do
    it { is_expected.to have_states :pending, :started }

    it { is_expected.to handle_events :finish, :to_failed, wnen: :pending }
    it { is_expected.to reject_events :finish, :to_failed, when: :finished }
    it { is_expected.to reject_events :finish, :to_failed, when: :failed }
  end
end
