describe Dialog do
  let(:message) { build_stubbed :message, from: user_1, to: user_2, read: false }
  subject(:dialog) { Dialog.new user_1, message }

  describe '#target_user' do
    context 'message from user' do
      its(:target_user) { is_expected.to eq user_2 }
    end

    context 'message to user' do
      let(:message) { build_stubbed :message, to: user_1, from: user_2 }
      its(:target_user) { is_expected.to eq user_2 }
    end
  end

  describe '#created_at' do
    its(:created_at) { is_expected.to eq message.created_at }
  end

  describe '#read' do
    context 'message from user' do
      its(:read) { is_expected.to eq true }
    end

    context 'message to user' do
      let(:message) { build_stubbed :message, to: user_1, from: user_2, read: false }
      its(:read) { is_expected.to eq false }
    end
  end

  describe '#my_message?' do
    context 'message from user' do
      its(:my_message?) { is_expected.to eq true }
    end

    context 'message to user' do
      let(:message) { build_stubbed :message, to: user_1, from: user_2 }
      its(:my_message?) { is_expected.to eq false }
    end
  end

  describe '#messages' do
    let!(:message_to) { create :message, from: user_2, to: user_1 }
    let!(:message_from) { create :message, from: user_1, to: user_2 }
    its(:messages) { is_expected.to eq [message_to, message_from] }
  end

  describe '#destroy' do
    let!(:message_to) { create :message, from: user_2, to: user_1 }
    let!(:message_from) { create :message, from: user_1, to: user_2 }

    before { dialog.destroy }

    it do
      expect { message_from.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(message_to.reload.is_deleted_by_to).to eq true
    end
  end

  describe '#new_message' do
    subject { dialog.new_message }

    it do
      is_expected.to be_kind_of Message
      is_expected.to have_attributes(
        body: nil,
        from_id: user_1.id,
        to_id: user_2.id,
        kind: MessageType::PRIVATE
      )
      is_expected.to be_new_record
    end
  end

  describe '#faye_channels' do
    let(:user_1) { build_stubbed :user, id: 2 }
    let(:user_2) { build_stubbed :user, id: 1 }

    its(:faye_channels) { is_expected.to eq ['/dialog-1-2'] }
  end
end
