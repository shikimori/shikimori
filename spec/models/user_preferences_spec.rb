describe UserPreferences do
  describe 'relations' do
    it { should belong_to :user }
  end

  describe 'validations' do
    it { should ensure_length_of(:default_sort).is_at_most(255) }
    it { should ensure_length_of(:page_background).is_at_most(255) }
    it { should ensure_length_of(:profile_privacy).is_at_most(255) }
    it { should ensure_length_of(:body_background).is_at_most(512) }
  end
end
