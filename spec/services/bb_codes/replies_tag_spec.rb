describe BbCodes::RepliesTag do
  let(:tag) { BbCodes::RepliesTag.instance }

  describe 'format' do
    subject { tag.format text }
    let(:comment_1) { create :comment }
    let(:comment_2) { create :comment }

    context 'no comments' do
      let(:text) { "<br><br>[replies=12345]" }
      it { should eq "" }
    end

    context 'one reply' do
      let(:text) { "<br><br>[replies=#{comment_1.id}]" }
      it { should eq "<div class=\"b-replies single\">[comment=#{comment_1.id}][/comment]</div>" }
    end

    context 'multiple replies' do
      let(:text) { "[replies=#{comment_1.id},#{comment_2.id},999]" }
      it { should eq "<div class=\"b-replies\">[comment=#{comment_1.id}][/comment], [comment=#{comment_2.id}][/comment]</div>" }
    end
  end
end

