describe NameMatch do
  describe 'relations'do
    it { is_expected.to belong_to :target }
  end

  describe 'validations'do
    it { is_expected.to validate_presence_of :target }
    it { is_expected.to validate_presence_of :phrase }
    it { is_expected.to validate_presence_of :group }
    it { is_expected.to validate_numericality_of(:group).is_greater_than_or_equal_to 0 }
    it { is_expected.to validate_presence_of :priority }
    it { is_expected.to validate_numericality_of(:priority).is_greater_than_or_equal_to 0 }
  end
end
