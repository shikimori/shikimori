describe BbCodes::Tags::BTag do
  let(:tag) { BbCodes::Tags::BTag.instance }

  describe '#format' do
    subject { tag.format '[b]test[/b]' }
    it { should eq '<strong>test</strong>' }
  end
end
