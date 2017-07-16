describe BbCodes::CommentTag do
  let(:tag) { BbCodes::CommentTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:user) { seed :user }
    let(:comment_url) { UrlGenerator.instance.comment_url comment }

    context 'with author' do
      let(:text) { "[comment=#{comment.id}]#{user.nickname}[/comment], test" }
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          "[url=#{comment_url} bubbled]@#{user.nickname}[/url], test"
        )
      end
    end

    context 'without author' do
      let(:text) { "[comment=#{comment.id}][/comment], test" }
      let(:comment) { create :comment, user: user }

      it do
        is_expected.to eq(
          "[url=#{comment_url} bubbled]@#{user.nickname}[/url], test"
        )
      end
    end
  end
end
