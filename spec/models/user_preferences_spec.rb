describe UserPreferences do
  describe 'relations' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should validate_length_of(:default_sort).is_at_most(255) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:list_privacy).in(:public, :users, :friends, :owner) }
    it { is_expected.to enumerize(:body_width).in(:x1200, :x1000) }
  end
end
