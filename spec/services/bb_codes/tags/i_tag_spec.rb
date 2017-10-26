describe BbCodes::Tags::ITag do
  let(:tag) { BbCodes::Tags::ITag.instance }

  describe '#format' do
    subject { tag.format '[i]test[/i]' }
    it { should eq '<em>test</em>' }
  end
end
