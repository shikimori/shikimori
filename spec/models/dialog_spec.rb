describe Dialog do
  let(:user) { build_stubbed :user }
  let(:target_user) { build_stubbed :user }
  let(:message) do
    build_stubbed :message,
      from: user,
      to: target_user,
      read: false
  end
  subject(:dialog) { Dialog.new user, message }

  describe '#target_user' do
    context 'message from user' do
      its(:target_user) { is_expected.to eq target_user }
    end

    context 'message to user' do
      let(:message) { build_stubbed :message, to: user, from: target_user }
      its(:target_user) { is_expected.to eq target_user }
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
      let(:message) { build_stubbed :message, to: user, from: target_user, read: false }
      its(:read) { is_expected.to eq false }
    end
  end

  describe '#my_message?' do
    context 'message from user' do
      its(:my_message?) { is_expected.to eq true }
    end

    context 'message to user' do
      let(:message) { build_stubbed :message, to: user, from: target_user }
      its(:my_message?) { is_expected.to eq false }
    end
  end

  describe '#messages' do
    let!(:message_to) { create :message, from: target_user, to: user }
    let!(:message_from) { create :message, from: user, to: target_user }
    its(:messages) { is_expected.to eq [message_to, message_from] }
  end

  describe '#destroy' do
    let(:user) { create :user }
    let(:target_user) { create :user }
    let!(:message_to) { create :message, from: target_user, to: user }
    let!(:message_from) { create :message, from: user, to: target_user }

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
        body: '',
        from_id: user.id,
        to_id: target_user.id,
        kind: MessageType::Private
      )
      is_expected.to be_new_record
    end
  end

  describe '#dialog' do
    let(:user) { build_stubbed :user, id: 2 }
    let(:target_user) { build_stubbed :user, id: 1 }

    its(:faye_channel) { is_expected.to eq ['dialog-1-2'] }
  end
end
