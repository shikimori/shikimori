describe DbEntries::Description do
  describe '.from_value' do
    let(:struct) { described_class.from_description description }

    context 'nil' do
      let(:description) { nil }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq nil
        expect(struct.description).to eq '[source][/source]'
      end
    end

    context 'empty string' do
      let(:description) { '' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq nil
        expect(struct.description).to eq '[source][/source]'
      end
    end

    context 'with text and source' do
      let(:description) { 'foo[source]bar[/source]' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq 'foo[source]bar[/source]'
      end
    end

    context 'with text, without source' do
      let(:description) { 'foo' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.description).to eq 'foo[source][/source]'
      end
    end

    context 'with text, with empty source' do
      let(:description) { 'foo[source][/source]' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.description).to eq 'foo[source][/source]'
      end
    end

    context 'without text, with source' do
      let(:description) { '[source]bar[/source]' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq '[source]bar[/source]'
      end
    end

    context 'with empty text, with source' do
      let(:description) { '[source]bar[/source]' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq '[source]bar[/source]'
      end
    end
  end

  describe '.from_text_source' do
    let(:struct) { described_class.from_text_source text, source }

    context 'with text and source' do
      let(:text) { 'foo' }
      let(:source) { 'bar' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq 'foo[source]bar[/source]'
      end
    end

    context 'with text, without source' do
      let(:text) { 'foo' }
      let(:source) { nil }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.description).to eq 'foo[source][/source]'
      end
    end

    context 'with text, with empty source' do
      let(:text) { 'foo' }
      let(:source) { '' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.description).to eq 'foo[source][/source]'
      end
    end

    context 'without text, with source' do
      let(:text) { nil }
      let(:source) { 'bar' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq '[source]bar[/source]'
      end
    end

    context 'with empty text, with source' do
      let(:text) { '' }
      let(:source) { 'bar' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.description).to eq '[source]bar[/source]'
      end
    end
  end
end
