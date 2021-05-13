describe BbCodes::Tags::SmileyTag do
  let(:tag) { described_class.new }
  let(:placeholder) { described_class::SMILEY_PLACEHOLDER }

  describe '#preprocess' do
    subject { tag.preprocess text }

    context 'sample' do
      let(:text) { ':)' }
      it { is_expected.to eq placeholder }
    end

    context 'sample' do
      let(:text) { 'z+_+z' }
      it { is_expected.to eq "z#{placeholder}z" }
    end

    context 'sample' do
      let(:text) { 'z+_+z :)' }
      it { is_expected.to eq "z#{placeholder}z #{placeholder}" }
    end
  end

  describe '#preprocess, #postprocess' do
    subject { tag.postprocess tag.preprocess(text) }

    context 'sample' do
      let(:text) { ':)' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <img
              src="/images/smileys/:).gif"
              alt=":)"
              title=":)"
              class="smiley"
            />
          HTML
        )
      end
    end

    context 'sample' do
      let(:text) { 'z+_+z :)' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            z<img
              src="/images/smileys/+_+.gif"
              alt="+_+"
              title="+_+"
              class="smiley"
            />z
            <img
              src="/images/smileys/:).gif"
              alt=":)"
              title=":)"
              class="smiley"
            />
          HTML
        )
      end
    end
  end
end
