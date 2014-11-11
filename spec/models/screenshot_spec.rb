describe Screenshot, :type => :model do
  context '#relations' do
    it { should belong_to :anime }
    it { should have_attached_file :image }
  end

  context '#validations' do
    it { should validate_presence_of :url }
    it { should validate_attachment_presence :image }
  end
end
