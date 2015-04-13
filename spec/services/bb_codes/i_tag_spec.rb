describe BbCodes::ITag do
  let(:tag) { BbCodes::ITag.instance }

  describe '#format' do
    subject { tag.format '[i]test[/i]' }
    it { should eq '<em>test</em>' }
  end
end
