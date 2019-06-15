describe Misc::SanitizeEvilCss do
  describe '#call' do
    subject { Misc::SanitizeEvilCss.call css }

    context 'evil css' do
      let(:css) { '&#1234; ' }
      it { is_expected.to eq '1234;' }
    end

    context 'no evil css' do
      let(:css) { 'background: red' }
      it { is_expected.to eq 'background: red' }
    end
  end
end
