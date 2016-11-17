describe DbEntries::Description do
  let(:struct) { described_class.new value: value }

  context 'value is nil' do
    let(:value) { nil }
    it do
      expect(struct.text).to eq nil
      expect(struct.source).to eq nil
    end
  end

  context 'value is empty string' do
    let(:value) { '' }
    it do
      expect(struct.text).to eq nil
      expect(struct.source).to eq nil
    end
  end

  context 'value with source' do
    let(:value) { 'foo[source]bar[/source]' }
    it do
      expect(struct.text).to eq 'foo'
      expect(struct.source).to eq 'bar'
    end
  end

  context 'value without source' do
    let(:value) { 'foo' }
    it do
      expect(struct.text).to eq 'foo'
      expect(struct.source).to eq nil
    end
  end
end
