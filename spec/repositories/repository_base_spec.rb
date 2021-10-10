describe RepositoryBase do
  class TestRepository < RepositoryBase
    def scope
      Genre.all
    end
  end

  let(:query) { TestRepository.instance }
  after { query.reset }

  describe '[]' do
    let!(:entry) { create :genre }
    it { expect(query[entry.id]).to eq entry }
  end

  describe '#reset' do
    let(:entry_id) { 999_999_999 }
    let(:create_entry) { create :genre, id: entry_id }

    it do
      expect(query[entry_id]).to be_nil
      create_entry
      expect(query[entry_id]).to be_nil

      query.reset

      expect(query[entry_id]).to eq create_entry
    end
    it { expect(query.reset).to eq true }
  end

  describe '#find' do
    let!(:entry) { create :genre, id: entry_id }
    let(:entry_id) { 999_999_999 }

    context 'block' do
      it { expect(query.find { |v| v.id == entry_id }).to eq entry }
    end

    context 'array' do
      it { expect(query.find([entry_id])).to eq [entry] }
    end

    context 'has entry' do
      it { expect(query.find(entry_id)).to eq entry }
    end

    context 'no entry' do
      let!(:entry) { nil }
      it do
        expect { query.find entry_id }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'new entry' do
      let!(:entry) { nil }
      let(:create_entry) { create :genre, id: entry_id }

      it do
        expect(query[entry_id]).to be_nil
        create_entry
        expect(query.find(entry_id)).to eq create_entry
      end
    end
  end

  describe '#to_a' do
    let!(:entry) { create :genre }
    it { expect(query.to_a).to eq [entry] }
  end
end
