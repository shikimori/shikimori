describe UserChange do
  describe 'relations' do
    it { should belong_to :user }
    it { should belong_to :approver }
  end

  describe 'validations' do
    it { should validate_numericality_of :user_id }
    it { should validate_numericality_of :item_id }
    it { should validate_presence_of :model }
  end
end
