describe UserImage do
  describe 'relations' do
    it { should belong_to :user }
    it { should belong_to :linked }
    it { should have_attached_file :image }
  end

  describe 'validations' do
    it { should validate_presence_of :user }
    it { should validate_attachment_presence :image }
  end
end
