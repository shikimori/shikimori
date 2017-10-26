describe BbCodes::Tags::STag do
  let(:tag) { BbCodes::Tags::STag.instance }

  describe '#format' do
    subject { tag.format '[s]test[/s]' }
    it { should eq '<del>test</del>' }
  end
end
