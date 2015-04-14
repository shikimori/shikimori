describe BbCodes::H3Tag do
  let(:tag) { BbCodes::H3Tag.instance }

  describe '#format' do
    subject { tag.format '[h3]test[/h3]' }
    it { should eq '<h3>test</h3>' }
  end
end
