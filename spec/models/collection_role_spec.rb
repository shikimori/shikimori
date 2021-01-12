describe CollectionRole do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:collection).touch(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to :collection_id }
  end

  describe 'permissions' do
    subject { Ability.new user }
    let(:user) { build_stubbed :user, :week_registered }

    let(:collection_role) do
      build_stubbed :collection_role, collection: collection, user: role_user
    end
    let(:role_user) { build_stubbed :user, :week_registered }

    let(:collection) { build_stubbed :collection, user: collection_owner }
    let(:collection_owner) { build_stubbed :user, :week_registered }

    context 'collection owner' do
      let(:collection_owner) { user }

      it { is_expected.to be_able_to :create, collection_role }
      it { is_expected.to be_able_to :destroy, collection_role }
    end

    context 'not collection owner' do
      it { is_expected.to_not be_able_to :create, collection_role }
      it { is_expected.to_not be_able_to :destroy, collection_role }
    end

    context 'collection_moderator' do
      let(:user) { build_stubbed :user, :collection_moderator }

      it { is_expected.to be_able_to :create, collection_role }
      it { is_expected.to be_able_to :destroy, collection_role }
    end

    context 'collection staff' do
      context 'own role' do
        let(:user) { role_user }

        it { is_expected.to_not be_able_to :create, collection_role }
        it { is_expected.to be_able_to :destroy, collection_role }
      end

      context 'not own role' do
        let(:user) { role_user }

        it { is_expected.to_not be_able_to :create, collection_role }
        it { is_expected.to be_able_to :destroy, collection_role }
      end
    end
  end
end
