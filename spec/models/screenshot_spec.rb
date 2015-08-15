describe Screenshot do
  describe 'relations' do
    it { should belong_to :anime }
    it { should have_attached_file :image }
  end

  describe 'validations' do
    it { should validate_presence_of :url }
    it { should validate_attachment_presence :image }
    it { should validate_presence_of :anime }
  end
end
