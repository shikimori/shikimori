describe NameMatch do
  describe 'relations'do
    it { is_expected.to belong_to :target }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:group).in *NameMatch::GROUPS }
  end

  describe 'validations'do
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :phrase }
    it { is_expected.to validate_presence_of :group }
  end
end
