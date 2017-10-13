describe PublishersRepository do
  let(:query) { PublishersRepository.instance }

  it { expect(query).to be_kind_of RepositoryBase }

  describe '[]' do
    let!(:publisher) { create :publisher }
    it { expect(query[publisher.id]).to eq publisher }
  end
end
