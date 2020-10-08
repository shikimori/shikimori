describe BbCodes::Tags::CommentTag do
  subject { described_class.instance.format text }

  let(:url) { UrlGenerator.instance.comment_url comment }

  context 'selfclosed' do
    let(:text) { "[comment=#{comment.id}], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]<s>@</s>#{user.nickname}[/url], test"
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          "<a href='#{url}' class='b-mention b-entry-404 bubbled'>"\
            "<s>@</s><del>[comment=#{comment.id}]</del></a>, test"
        )
      end
    end
  end

  context 'double match' do
    let(:comment) { create :comment, user: user }
    let(:comment_2) { create :comment, user: user_2 }
    let(:text) do
      "[comment=#{comment.id}], test [comment=#{comment_2.id}]qwe[/comment]"
    end
    let(:url_2) { UrlGenerator.instance.comment_url comment_2 }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]<s>@</s>#{user.nickname}[/url], test " \
          "[url=#{url_2} bubbled b-mention]<s>@</s>qwe[/url]"
      )
    end
  end

  context 'with author' do
    let(:text) { "[comment=#{comment.id}]#{user.nickname}[/comment], test" }
    let(:comment) { create :comment }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]<s>@</s>#{user.nickname}[/url], test"
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          "<a href='#{url}' class='b-mention b-entry-404 bubbled'>"\
          "<s>@</s><span>#{user.nickname}</span><del>[comment=#{comment.id}]</del></a>, test"
        )
      end
    end
  end

  context 'without author' do
    let(:text) { "[comment=#{comment.id}][/comment], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        "[url=#{url} bubbled b-mention]<s>@</s>#{user.nickname}[/url], test"
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          "<a href='#{url}' class='b-mention b-entry-404 bubbled'>"\
            "<s>@</s><del>[comment=#{comment.id}]</del></a>, test"
        )
      end
    end
  end

  context 'quote' do
    let(:text) { "[comment=#{comment.id} quote]#{user.nickname}[/comment], test" }
    let(:comment) { create :comment, user: user }

    context 'with avatar' do
      let(:user) { create :user, :with_avatar }
      it do
        is_expected.to eq(
          "[url=#{url} bubbled b-mention b-user16]<img "\
            "src=\"#{ImageUrlGenerator.instance.url user, :x16}\" "\
            "srcset=\"#{ImageUrlGenerator.instance.url user, :x32} 2x\" "\
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
