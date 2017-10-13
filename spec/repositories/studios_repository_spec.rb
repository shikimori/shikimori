describe StudiosRepository do
  let(:query) { StudiosRepository.instance }

  it { expect(query).to be_kind_of RepositoryBase }

  describe '[]' do
    let!(:studio) { create :studio }
    it { expect(query[studio.id]).to eq studio }
  end
end
