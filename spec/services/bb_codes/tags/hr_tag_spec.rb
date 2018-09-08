describe BbCodes::Tags::HrTag do
  let(:tag) { BbCodes::Tags::HrTag.instance }

  describe '#format' do
    subject { tag.format '[hr][hr]' + ["\r\n", "\r", "\n", '<br>'].sample }
    it { is_expected.to eq '<hr><hr>' }
  end
end
