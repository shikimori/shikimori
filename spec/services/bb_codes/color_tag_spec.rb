describe BbCodes::ColorTag do
  let(:tag) { BbCodes::ColorTag.instance }

  describe '#format' do
    context 'name' do
      subject { tag.format '[color=red]test[/color]' }
      it { should eq '<span style="color: red;">test</span>' }
    end

    context 'code' do
      subject { tag.format '[color=#00ff00]test[/color]' }
      it { should eq '<span style="color: #00ff00;">test</span>' }
    end

    context 'xss' do
      subject { tag.format '[color=#00ff00</span><script>]test[/color]' }
      it { should eq '[color=#00ff00</span><script>]test[/color]' }
    end
  end
end
