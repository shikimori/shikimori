describe Repos::Publishers do
  let(:query) { Repos::Publishers.instance }

  it { expect(query).to be_kind_of Repos::RepositoryBase }

  describe '[]' do
    let!(:publisher) { create :publisher }
    it { expect(query[publisher.id]).to eq publisher }
  end
end
