describe Repos::Studios do
  let(:query) { Repos::Studios.instance }

  it { expect(query).to be_kind_of Repos::RepositoryBase }

  describe '[]' do
    let!(:studio) { create :studio }
    it { expect(query[studio.id]).to eq studio }
  end
end
