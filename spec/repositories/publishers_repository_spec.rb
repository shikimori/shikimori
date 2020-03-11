describe PublishersRepository do
  let(:query) { described_class.instance }

  before { query.reset }

  it { expect(query).to be_kind_of RepositoryBase }

  describe '[]' do
    let!(:publisher) { create :publisher }
    it { expect(query[publisher.id]).to eq publisher }
  end
end
