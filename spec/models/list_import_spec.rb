describe ListImport do
  describe 'relations' do
    it { is_expected.to belong_to :user }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
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
