describe BbCodes::HrTag do
  let(:tag) { BbCodes::HrTag.instance }

  describe '#format' do
    subject { tag.format '[hr][hr]' }
    it { should eq '<hr /><hr />' }
  end
end
