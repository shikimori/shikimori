describe BbCodes::Tags::UserTag do
  subject { described_class.instance.format text }

  let(:text) { "[user=#{user.id}], test" }
  let(:url) { UrlGenerator.instance.profile_url user }
  let(:attrs) { { id: user.id, type: :user, text: user.nickname } }

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention'
          data-attrs='#{attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  context 'with text' do
    let(:text) { "[user=#{user.id}]test[/user], test" }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='http://test.host/#{user.nickname}' class='b-mention'
            data-attrs='#{attrs.to_json}'><s>@</s><span>test</span></a>, test
        HTML
      )
    end
  end

  context 'non existing user' do
    let(:user) { build_stubbed :user }
    let(:attrs) { { id: user.id, type: :user } }

    it do
      is_expected.to eq(
        "<span class='b-mention b-entry-404' data-attrs='#{attrs.to_json}'><s>@</s>" \
          "<del>[user=#{user.id}]</del></span>, test"
      )
    end
  end
end
