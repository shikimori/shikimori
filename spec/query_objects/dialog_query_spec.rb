describe DialogQuery do
  let(:target_user) { create :user }
  let(:user_3) { create :user }
  let(:query) { DialogQuery.new user, target_user }

  let(:id) { message_to_1.id }
  let!(:message_to_1) do
    create :message,
      from: target_user,
      to: user,
      created_at: 2.hours.ago
  end
  let!(:message_from_1) do
    create :message,
      from: user,
      to: target_user,
      created_at: 1.hour.ago,
      id: id + 1
  end
  let!(:message_to_2) { create :message, from: user, to: user_3, id: id + 2 }

  describe '#fetch' do
    subject(:fetch) { query.fetch 1, 1, true }
    it { is_expected.to eq [message_to_1, message_from_1] }

    describe 'message_to_1' do
      context 'deleted by receiver' do
        let!(:message_to_1) do
          create :message,
            from: target_user,
            to: user,
            is_deleted_by_to: true,
            created_at: 2.hours.ago
        end
        it { is_expected.to eq [message_from_1] }
      end
    end

    describe 'message_from_1' do
      context 'deleted by receiver' do
        let!(:message_from_1) do
          create :message,
            from: user,
            to: target_user,
            is_deleted_by_to: true,
            created_at: 2.hours.ago,
            id: id + 1
        end
        it { is_expected.to eq [message_to_1, message_from_1] }
      end
    end
  end

  describe '#postload' do
    let!(:message_to_2) do
      create :message,
        from: target_user,
        to: user,
        created_at: 1.hour.ago,
        id: id + 2
    end
    let!(:message_from_2) do
      create :message,
        from: user,
        to: target_user,
        id: id + 3
    end

    subject(:postload) { query.postload 1, 15 }

    its(:first) { is_expected.to eq [message_from_1, message_to_2, message_from_2] }
    its(:second) { is_expected.to eq true }
  end
end
