describe BbCodes::SolidTag do
  let(:tag) { BbCodes::SolidTag.instance }

  describe '#format' do
    subject { tag.format '[solid]test[/solid]' }
    it { should eq '<div class="solid">test</div>' }
  end
end
