describe DbEntries::Destroy do
  let(:worker) { described_class.new }

  before { allow_any_instance_of(Anime).to receive(:destroy!).and_call_original }
  subject! { worker.perform type, id, user_id }

  let!(:anime) { create :anime }

  let(:id) { anime.id }
  let(:type) { 'Anime' }
  let(:user_id) { user.id }

  it do
    expect { anime.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
