describe BbCodes::Tags::CommentTag do
  subject { described_class.instance.format text }

  let(:comment) { build_stubbed :comment }
  let(:comment_url) { UrlGenerator.instance.comment_url comment }

  context 'quote' do
    let(:comment) { create :comment, user: user }
    let(:text) { "[comment=#{comment.id} quote]#{user.nickname}[/comment], test" }

    context 'with avatar' do
      let(:user) { create :user, :with_avatar }
      it do
        is_expected.to eq(
          "[url=#{comment_url} bubbled b-user16]<img "\
            "src=\"#{user.avatar_url 16}\" "\
            "srcset=\"#{user.avatar_url 32} 2x\" "\
            "alt=\"#{ERB::Util.h user.nickname}\" />"\
            "<span>#{user.nickname}</span>[/url], test"
        )
      end
    end

    context 'without avatar' do
      it do
        is_expected.to eq(
          "[url=#{comment_url} bubbled b-user16]"\
            "<span>#{user.nickname}</span>[/url], test"
        )
      end
    end
  end

  context 'with author' do
    let(:text) { "[comment=#{comment.id}]#{user.nickname}[/comment], test" }

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
