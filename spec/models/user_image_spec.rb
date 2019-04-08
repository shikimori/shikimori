describe UserImage do
  describe 'relations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:linked).optional }
    it { is_expected.to have_attached_file :image }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_attachment_presence :image }
  end
end
