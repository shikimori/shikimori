describe BbCodes::Tags::CommentTag do
  subject { described_class.instance.format text }

  let(:url) { UrlGenerator.instance.comment_url comment }

  context 'selfclosed' do
    let(:text) { "[comment=#{comment.id}], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention bubbled'
            data-id='#{comment.id}' data-type='comment'
              data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
        HTML
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention b-entry-404 bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text=''><s>@</s><del>[comment=#{comment.id}]</del></a>, test
          HTML
        )
      end
    end

    context 'with user_id' do
      let(:text) { "[comment=#{comment.id};#{user.id}], test" }
      let(:comment) { create :comment, user: user }

      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
          HTML
        )
      end

      context 'non existing comment' do
        let(:comment) { build_stubbed :comment }

        it do
          is_expected.to eq(
            <<~HTML.squish
              <a href='#{url}' class='b-mention b-entry-404 bubbled'
                data-id='#{comment.id}' data-type='comment'
                data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span><del>[comment=#{comment.id}]</del></a>, test
            HTML
          )
        end
      end
    end
  end

  context 'with author' do
    let(:text) { "[comment=#{comment.id}]#{user.nickname}[/comment], test" }
    let(:comment) { create :comment }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention bubbled'
            data-id='#{comment.id}' data-type='comment'
            data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
        HTML
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention b-entry-404 bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text=''><s>@</s><span>#{user.nickname}</span><del>[comment=#{comment.id}]</del></a>, test
          HTML
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
        <<~HTML.squish
          <a href='#{url}' class='b-mention bubbled'
            data-id='#{comment.id}' data-type='comment'
            data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
          <a href='http://test.host/comments/#{comment_2.id}' class='b-mention bubbled'
            data-id='#{comment_2.id}' data-type='comment'
            data-text='#{user_2.nickname}'><s>@</s><span>qwe</span></a>
        HTML
      )
    end
  end

  context 'without author' do
    let(:text) { "[comment=#{comment.id}][/comment], test" }
    let(:comment) { create :comment, user: user }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention bubbled'
            data-id='#{comment.id}' data-type='comment'
            data-text='#{user.nickname}'><s>@</s><span>#{user.nickname}</span></a>, test
        HTML
      )
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }

      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention b-entry-404 bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text=''><s>@</s><del>[comment=#{comment.id}]</del></a>, test
          HTML
        )
      end
    end
  end

  context 'quote' do
    let(:text) { "[comment=#{comment.id} #{quote_part}]#{user.nickname}[/comment], test" }
    let(:comment) { create :comment, user: user }
    let(:quote_part) { 'quote' }

    context 'with avatar' do
      let(:user) { create :user, :with_avatar }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}'
              class='b-mention bubbled b-user16'
              data-id='#{comment.id}' data-type='comment'
              data-text='#{user.nickname}'><img
              src="#{ImageUrlGenerator.instance.url user, :x16}"
              srcset="#{ImageUrlGenerator.instance.url user, :x32} 2x"
              alt="#{ERB::Util.h user.nickname}" /><span>#{user.nickname}</span></a>, test
          HTML
        )
      end
    end

    context 'without avatar' do
      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text='#{user.nickname}'><span>#{user.nickname}</span></a>, test
          HTML
        )
      end
    end

    context 'non existing comment' do
      let(:comment) { build_stubbed :comment }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <a href='#{url}' class='b-mention b-entry-404 bubbled'
              data-id='#{comment.id}' data-type='comment'
              data-text=''><s>@</s><span>#{user.nickname}</span><del>[comment=#{comment.id}]</del></a>, test
          HTML
        )
      end

      context 'quote with user_id' do
        let(:quote_part) { "quote=#{user.id}" }
        it do
          is_expected.to eq(
            "[user=#{user.id}]#{user.nickname}[/user]" \
              "<span class='b-mention b-entry-404'><del>[comment=#{comment.id}]</del></span>, test"
          )
        end
      end
    end
  end
end
