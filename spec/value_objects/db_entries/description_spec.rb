describe DbEntries::Description do
  let(:struct) { described_class.new value: value }

  context 'nil' do
    let(:value) { nil }
    it do
      expect(struct.text).to eq nil
      expect(struct.source).to eq nil
    end
  end

  context 'empty string' do
    let(:value) { '' }
    it do
      expect(struct.text).to eq nil
      expect(struct.source).to eq nil
    end
  end

  context 'with text and source' do
    let(:value) { 'foo[source]bar[/source]' }
    it do
      expect(struct.text).to eq 'foo'
      expect(struct.source).to eq 'bar'
    end
  end

  context 'with text, without source' do
    let(:value) { 'foo' }
    it do
      expect(struct.text).to eq 'foo'
      expect(struct.source).to eq nil
    end
  end

  context 'with text, with empty source' do
    let(:value) { 'foo[source][/source]' }
    it do
      expect(struct.text).to eq 'foo'
      expect(struct.source).to eq nil
    end
  end

  context 'without text, with source' do
    let(:value) { '[source]bar[/source]' }
    it do
      expect(struct.text).to eq nil
      expect(struct.source).to eq 'bar'
    end
  end
end
