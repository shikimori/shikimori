describe BbCodes::BrTag do
  let(:tag) { BbCodes::BrTag.instance }

  describe '#format' do
    subject { tag.format '[br]test' }
    it { should eq '<br>test' }
  end
end
