describe BbCodes::Tags::SolidTag do
  let(:tag) { BbCodes::Tags::SolidTag.instance }

  describe '#format' do
    subject { tag.format '[solid]test[/solid]' }
    it { should eq '<div class="solid">test</div>' }
  end
end
