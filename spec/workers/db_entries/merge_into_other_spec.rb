describe DbEntries::MergeIntoOther do
  let(:worker) { described_class.new }

  before { allow(DbEntry::MergeIntoOther).to receive(:call).and_call_original }
  subject! { worker.perform type, from_id, to_id, user_id }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }

  let(:from_id) { anime_1.id }
  let(:to_id) { anime_2.id }
  let(:type) { 'Anime' }
  let(:user_id) { user.id }

  it do
    expect(DbEntry::MergeIntoOther)
      .to have_received(:call)
      .with(entry: anime_1, other: anime_2)

    expect { anime_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(anime_2.reload).to be_persisted
  end
end
