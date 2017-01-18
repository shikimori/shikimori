describe MalParsers::FetchEntryAuthorized do
  let(:worker) { MalParsers::FetchEntryAuthorized.new }

  describe '#perform', :vcr do
    let(:anime_id) { 28_851 }

    subject! { worker.perform anime_id }

    it do
      expect(subject).to be_persisted
      expect(subject.reload.external_links).to have(4).items
    end
  end
end
