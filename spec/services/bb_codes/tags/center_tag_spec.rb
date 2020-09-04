describe BbCodes::Tags::CenterTag do
  subject { described_class.instance.format text }
  let(:text) { '[center]test[/center]' }
  it { is_expected.to eq '<center>test</center>' }

  describe 'nesting' do
    before { stub_const "#{described_class.name}::MAX_NESTING", 2 }

    context 'MAX_NESTING' do
      let(:text) { 'a[center]b[center]d[/center]e[/center]f' }
      it { is_expected.to eq 'a<center>b<center>d</center>e</center>f' }
    end

    context 'MAX_NESTING + 1' do
      let(:text) { 'a[center]b[center]c[center]d[/center]e[/center]f[/center]g' }
      it do
        is_expected.to_not eq(
          'a<center>b<center>c<center>d</center>e</center>f</center>g'
        )
        is_expected.to eq(
          'a<center>b<center>c[center]d</center>e</center>f[/center]g'
        )
      end
    end
  end
end
