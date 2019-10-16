describe Favourite do
  describe 'relations' do
    it { is_expected.to belong_to :linked }
    it { is_expected.to belong_to :user }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(*Types::Favourite::Kinds.values) }
    it { is_expected.to enumerize(:linked_type).in(*Types::Favourite::LinkedTypes.values) }
  end

  describe 'validations' do
    Types::Favourite::LinkedTypes.values.each do |linked_type|
      context linked_type do
        before { subject.linked_type = linked_type }

        if linked_type == Types::Favourite::LinkedTypes['Person']
          it { is_expected.to validate_presence_of :kind }
        else
          it { is_expected.to_not validate_presence_of :kind }
        end
      end
    end
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
