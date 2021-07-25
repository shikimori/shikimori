describe Studio do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:short_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:japanese).is_at_most(255) }
    it { is_expected.to validate_length_of(:ani_db_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:description_ru).is_at_most(16384) }
    it { is_expected.to validate_length_of(:description_en).is_at_most(16384) }
  end
end
