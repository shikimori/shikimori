describe UserChange do
  context '#relations' do
    it { should belong_to :user }
    it { should belong_to :approver }
  end

  context '#validations' do
    it { should validate_numericality_of :user_id }
    it { should validate_numericality_of :item_id }
    it { should validate_presence_of :model }
  end

  context '#hooks' do
    describe :release_lock do
      let(:anime) { create :anime }
      let(:anime2) { create :anime }

      before do
        create :user_change, user_id: 1, item_id: anime.id, model: anime.class.name, status: UserChangeStatus::Locked
        create :user_change, user_id: 1, item_id: anime2.id, model: anime.class.name, status: UserChangeStatus::Locked
      end

      it 'destroys previously created lock' do
        lock_query = UserChange.where(model: anime.class.name, item_id: anime.id, status: UserChangeStatus::Locked)
        expect {
          create :user_change, user_id: 2, item_id: anime.id, model: anime.class.name, column: 'description', status: UserChangeStatus::Pending
        }.to change(lock_query, :count).by -1
      end
    end
  end
end
