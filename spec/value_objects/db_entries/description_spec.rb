describe DbEntries::Description do
  describe '.from_value' do
    let(:struct) { described_class.from_value value }

    context 'nil' do
      let(:value) { nil }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq nil
        expect(struct.value).to eq ''
      end
    end

    context 'empty string' do
      let(:value) { '' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq nil
        expect(struct.value).to eq ''
      end
    end

    context 'with text and source' do
      let(:value) { "foo\nbar[source]baz[/source]" }
      it do
        expect(struct.text).to eq "foo\nbar"
        expect(struct.source).to eq 'baz'
        expect(struct.value).to eq "foo\nbar[source]baz[/source]"
      end
    end

    context 'with text, without source' do
      let(:value) { 'foo' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.value).to eq 'foo'
      end
    end

    context 'with text, with empty source' do
      let(:value) { 'foo[source][/source]' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.value).to eq 'foo'
      end
    end

    context 'without text, with source' do
      let(:value) { '[source]bar[/source]' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.value).to eq '[source]bar[/source]'
      end
    end

    context 'with empty text, with source' do
      let(:value) { '[source]bar[/source]' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.value).to eq '[source]bar[/source]'
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
        expect(struct.value).to eq 'foo[source]bar[/source]'
      end
    end

    context 'with text, without source' do
      let(:text) { 'foo' }
      let(:source) { nil }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.value).to eq 'foo'
      end
    end

    context 'with text, with empty source' do
      let(:text) { 'foo' }
      let(:source) { '' }
      it do
        expect(struct.text).to eq 'foo'
        expect(struct.source).to eq nil
        expect(struct.value).to eq 'foo'
      end
    end

    context 'without text, with source' do
      let(:text) { nil }
      let(:source) { 'bar' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.value).to eq '[source]bar[/source]'
      end
    end

    context 'with empty text, with source' do
      let(:text) { '' }
      let(:source) { 'bar' }
      it do
        expect(struct.text).to eq nil
        expect(struct.source).to eq 'bar'
        expect(struct.value).to eq '[source]bar[/source]'
      end
    end
  end

  describe '.value' do
    let(:struct) { described_class.from_value value }

    context 'with source' do
      let(:value) { 'foo[source]bar[/source]' }
      it { expect(struct.value).to eq value }
    end

    context 'without source' do
      let(:value) { 'foo' }
      it { expect(struct.value).to eq value }
    end

    context 'with empty source' do
      let(:value) { 'foo[source][/source]' }
      it { expect(struct.value).to eq 'foo' }
    end
  end
end
