describe Misc::SanitizeEvilCss do
  describe '#call' do
    subject { Misc::SanitizeEvilCss.call css }

    context 'evil css' do
      context 'sample' do
        let(:css) { 'a { color: &#1234; }' }
        it { is_expected.to eq 'a { color: 1234; }' }
      end

      context 'sample' do
        let(:css) { '@import url(evil.css);' }
        it { is_expected.to eq '' }
      end

      context 'sample' do
        let(:css) { '@im@importport url(http://evil.css)' }
        it { is_expected.to eq 'url(http://evil.css)' }
      end

      context 'sample' do
        let(:css) { '@im/**/port url(http://evil.css);' }
        it { is_expected.to eq '' }
      end

      context 'sample' do
        let(:css) { '@@@import url();import url();import url(http://evil.css);' }
        it { is_expected.to eq '' }
      end
    end

    context 'no evil css' do
      let(:css) { 'a { background: red }' }
      it { is_expected.to eq 'a { background: red }' }
    end
  end
end
