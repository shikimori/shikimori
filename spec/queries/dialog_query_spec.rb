describe DialogQuery do
  let(:user) { create :user }
  let(:target_user) { create :user }
  let(:user_3) { create :user }
  let(:query) { DialogQuery.new user, target_user }

  let(:id) { message_to_1.id }
  let!(:message_to_1) { create :message, from: target_user, to: user, created_at: 2.hours.ago }
  let!(:message_from_1) { create :message, from: user, to: target_user, created_at: 1.hour.ago, id: id+1 }
  let!(:message_to_2) { create :message, from: user, to: user_3, id: id+2 }

  describe '#fetch' do
    subject(:fetch) { query.fetch 1, 1 }
    it { should eq [message_to_1, message_from_1] }

    describe 'message_to_1' do
      context 'deleted by receiver' do
        let!(:message_to_1) { create :message, from: target_user, to: user, dst_del: true, created_at: 2.hours.ago }
        it { should eq [message_from_1] }
      end

      context 'deleted by sender' do
        let!(:message_to_1) { create :message, from: target_user, to: user, src_del: true, created_at: 2.hours.ago }
        it { should eq [message_to_1, message_from_1] }
      end
    end

    describe 'message_from_1' do
      context 'deleted by receiver' do
        let!(:message_from_1) { create :message, from: user, to: target_user, dst_del: true, created_at: 2.hours.ago, id: id+1 }
        it { should eq [message_to_1, message_from_1] }
      end

      context 'deleted by sender' do
        let!(:message_from_1) { create :message, from: user, to: target_user, src_del: true, created_at: 2.hours.ago, id: id+1 }
        it { should eq [message_to_1] }
      end
    end
  end

  describe '#postload' do
    let!(:message_to_2) { create :message, from: target_user, to: user, created_at: 1.hour.ago, id: id+2 }
    let!(:message_from_2) { create :message, from: user, to: target_user, id: id+3 }

    subject(:postload) { query.postload 1, 15 }

    its(:first) { should eq [message_from_1, message_to_2, message_from_2] }
    its(:second) { should be_truthy }
  end
end
