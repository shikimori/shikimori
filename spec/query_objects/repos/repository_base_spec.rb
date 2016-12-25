describe Repos::RepositoryBase do
  class Repos::Test < Repos::RepositoryBase
    def scope
      Genre.all
    end
  end

  let(:query) { Repos::Test.instance }
  after { query.reset }

  describe '[]' do
    let!(:entry) { create :genre }
    it { expect(query[entry.id]).to eq entry }
  end

  describe '#reset' do
    let(:entry_id) { 999_999_999 }

    it do
      expect(query[entry_id]).to be_nil
      entry = create :genre, id: entry_id
      expect(query[entry_id]).to be_nil

      query.reset

      expect(query[entry_id]).to eq entry
    end
  end
end
