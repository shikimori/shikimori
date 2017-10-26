describe BbCodes::Tags::PTag do
  let(:tag) { BbCodes::Tags::PTag.instance }

  describe '#format' do
    subject { tag.format '[p]test[/p]' }
    it { should eq '<div class="b-prgrph">test</div>' }
  end
end
