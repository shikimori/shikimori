describe BbCodes::RepliesTag do
  let(:tag) { BbCodes::RepliesTag.instance }

  describe 'format' do
    subject { tag.format text }
    let(:comment) { create :comment }

    context 'one reply' do
      let(:text) { "<br><br>[replies=1]" }
      it { should eq "<div class=\"b-replies single\">[comment=1][/comment]</div>" }
    end

    context 'multiple replies' do
      let(:text) { "[replies=1,2]" }
      it { should eq "<div class=\"b-replies\">[comment=1][/comment], [comment=2][/comment]</div>" }
    end
  end
end

