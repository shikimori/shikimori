describe BbCodes::WallTag do
  let(:tag) { BbCodes::WallTag.instance }

  describe '#format' do
    subject { tag.format '[wall]test[/wall]' }
    it { should eq '<div class="b-shiki_wall unprocessed">test</div>' }
  end
end
