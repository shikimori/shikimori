describe Favourite do
  describe 'relations' do
    it { is_expected.to belong_to :linked }
    it { is_expected.to belong_to :user }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::Favourite::Kind.values) }
    it { is_expected.to enumerize(:linked_type).in(*Types::Favourite::LinkedType.values) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :kind }
  end

  describe 'permissions' do
    let(:favourite) { build_stubbed :favourite, user: favourite_user }
    let(:user) { build_stubbed :user }

    subject { Ability.new user }

    context 'favourite owner' do
      let(:favourite_user) { user }
      it { is_expected.to be_able_to :manage, favourite }
    end

    context 'favourite owner' do
      let(:favourite_user) { build_stubbed :user }
      it { is_expected.to_not be_able_to :manage, favourite }
    end
  end
end
