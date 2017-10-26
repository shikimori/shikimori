describe BbCodes::Tags::BrTag do
  let(:tag) { BbCodes::Tags::BrTag.instance }

  describe '#format' do
    subject { tag.format '[br]test' }
    it { should eq '<br>test' }
  end
end
