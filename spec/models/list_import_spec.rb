describe ListImport do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user } end

  describe 'enumerize' do
    it do
      is_expected
        .to enumerize(:list_type)
        .in(*Types::ListImport::ListType.values)
      is_expected
        .to enumerize(:duplicate_policy)
        .in(*Types::ListImport::DuplicatePolicy.values)
    end
  end

  describe 'state_machine' do
    it { is_expected.to have_states :pending, :finished, :failed }

    it { is_expected.to handle_events :finish, :to_failed, wnen: :pending }
    it { is_expected.to reject_events :finish, :to_failed, when: :finished }
    it { is_expected.to reject_events :finish, :to_failed, when: :failed }
  end

  describe 'callbacks' do
    describe '#schedule_worker' do
      let(:list_import) { build :list_import, :with_schedule }
      before { allow(ListImports::Worker).to receive :perform_async }
      subject! { list_import.save! }

      it do
        expect(ListImports::Worker)
          .to have_received(:perform_async)
          .with list_import.id
      end
    end
  end

  describe 'instance methods' do
    describe '#name' do
      let(:list_import) { build_stubbed :list_import }
      it { expect(list_import.name).to eq "Импорт списка ##{list_import.id}" }
    end

    describe '#empty_list_error?, #mismatched_list_type_error?' do
      context 'ERROR_EXCEPTION' do
        let(:list_import) { build_stubbed :list_import, :error_exception }
        it { expect(list_import).to_not be_empty_list_error }
        it { expect(list_import).to_not be_mismatched_list_type_error }
      end

      context 'ERROR_EMPTY_LIST' do
        let(:list_import) { build_stubbed :list_import, :error_empty_list }
        it { expect(list_import).to be_empty_list_error }
        it { expect(list_import).to_not be_mismatched_list_type_error }
      end

      context 'ERROR_MISMATCHED_LIST_TYPE' do
        let(:list_import) { build_stubbed :list_import, :error_mismatched_list_type }
        it { expect(list_import).to_not be_empty_list_error }
        it { expect(list_import).to be_mismatched_list_type_error }
      end
    end
  end

  describe 'permissions' do
    let(:list_import) { build :list_import, user: import_user }
    let(:user) { build_stubbed :user }

    subject { Ability.new user }

    context 'import owner' do
      let(:import_user) { user }

      it { is_expected.to be_able_to :new, list_import }
      it { is_expected.to be_able_to :create, list_import }
      it { is_expected.to be_able_to :show, list_import }
    end

    context 'not import owner' do
      let(:import_user) { build_stubbed :user }

      it { is_expected.to_not be_able_to :new, list_import }
      it { is_expected.to_not be_able_to :create, list_import }
      it { is_expected.to_not be_able_to :show, list_import }
    end
  end
end
