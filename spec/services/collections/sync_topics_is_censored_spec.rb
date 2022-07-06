describe Collections::SyncTopicsIsCensored do
  let(:entry) { create :collection, is_censored: is_censored }
  let(:is_censored) { false }
  let!(:collection_topic) do
    create :collection_topic, linked: entry, is_censored: !is_censored
  end

  subject! { Collections::SyncTopicsIsCensored.call entry }

  it do
    expect(collection_topic.reload.is_censored).to eq is_censored
  end
end
