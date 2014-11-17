describe AnimeLink do
  describe 'relations' do
    it { should belong_to :anime }
  end

  describe 'validations' do
    it { should validate_presence_of :anime }
    it { should validate_presence_of :service }
    it { should validate_presence_of :identifier }
  end
end
