describe Topic::Destroy do
  subject { described_class.call topic, faye }

  let(:faye) { FayeService.new user, nil }
  let!(:topic) { create :topic }

  it do
    expect { subject }.to change(Topic, :count).by(-1)
    expect { topic.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
