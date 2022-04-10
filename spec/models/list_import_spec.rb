describe ListImport do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
  end

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

  describe 'aasm' do
    it { is_expected.to have_states :pending, :finished, :failed }

    it { is_expected.to allow_event :finish, :to_failed, wnen: :pending }
    it { is_expected.to_not allow_event :finish, :to_failed, on: :finished }
    it { is_expected.to_not allow_event :finish, :to_failed, on: :failed }
  end

  describe 'callbacks' do
    describe '#schedule_worker' do
      let(:list_import) { build :list_import, :with_schedule }
      before { allow(ListImports::ImportWorker).to receive :perform_async }
      subject! { list_import.save! }

      it do
        expect(ListImports::ImportWorker)
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
