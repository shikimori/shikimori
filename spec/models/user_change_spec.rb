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

  describe 'instance methods' do
    describe '#reason=' do
      let(:user_change) { build :user_change, reason: 'a' * 3000 }
      it { expect(user_change.reason).to have(UserChange::MAXIMUM_REASON_SIZE).items }
    end
  end
end
