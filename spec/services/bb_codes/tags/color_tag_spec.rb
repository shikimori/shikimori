describe BbCodes::Tags::ColorTag do
  subject { described_class.instance.format text }

  context 'name' do
    let(:text) { '[color=red]test[/color]' }
    it { should eq '<span style="color: red;">test</span>' }
  end

  context 'code' do
    let(:text) { '[color=#00ff00]test[/color]' }
    it { should eq '<span style="color: #00ff00;">test</span>' }
  end

  context 'xss' do
    let(:text) { '[color=#00ff00</span><script>]test[/color]' }
    it { should eq '[color=#00ff00</span><script>]test[/color]' }
  end
end
