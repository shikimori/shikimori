describe Notifications::SendMessages do
  include_context :timecop
  subject(:messages) { described_class.new.perform message_attributes, user_ids }
  let(:user_ids) { [1, 2, 3] }

  let(:message_attributes) do
    {
      'created_at' => 1.day.ago,
      'from_id' => user.id,
      'kind' => MessageType::SITE_NEWS,
      'linked_id' => 1,
      'linked_type' => Topic.name
    }
  end

  it do
    expect { subject }.to change(Message, :count).by user_ids.count
    is_expected.to have(user_ids.size).items

    expect(messages.first).to have_attributes(
      message_attributes.except('created_at')
    )
    expect(messages.first.created_at).to be_within(0.1).of 1.day.ago
    expect(messages.first.to_id).to eq user_ids.first
    expect(messages.second.to_id).to eq user_ids.second
    expect(messages.third.to_id).to eq user_ids.third
  end
end
