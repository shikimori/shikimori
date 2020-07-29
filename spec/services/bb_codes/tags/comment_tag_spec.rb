describe BbCodes::Tags::CommentTag do
  subject { described_class.instance.format text }

  let(:url) { UrlGenerator.instance.comment_url comment }

  context 'selfclosed' do
    let(:text) { "[comment=#{comment.id}], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]#{user.nickname}[/url], test"
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }
      let(:text) { "[comment=#{comment.id}], test" }
      it do
        is_expected.to eq(
          "[url=#{url} b-mention]#{described_class::NOT_FOUND}[/url], test"
        )
      end
    end
  end

  context 'with author' do
    let(:comment) { create :comment }
    let(:text) { "[comment=#{comment.id}]#{user.nickname}[/comment], test" }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]#{user.nickname}[/url], test"
      )
    end
  end

  context 'without author' do
    let(:text) { "[comment=#{comment.id}][/comment], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]#{user.nickname}[/url], test"
      )
    end
  end

  context 'quote' do
    let(:comment) { create :comment, user: user }
    let(:text) { "[comment=#{comment.id} quote]#{user.nickname}[/comment], test" }

    context 'with avatar' do
      let(:user) { create :user, :with_avatar }
      it do
        is_expected.to eq(
          "[url=#{url} bubbled b-mention b-user16]<img "\
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
          "[url=#{url} bubbled b-mention b-user16]"\
            "<span>#{user.nickname}</span>[/url], test"
        )
      end
    end
  end
end
