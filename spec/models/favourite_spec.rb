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
end
