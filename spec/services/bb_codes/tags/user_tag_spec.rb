describe BbCodes::Tags::UserTag do
  subject { described_class.instance.format text }

  let(:text) { "[user=#{user.id}], test" }
  let(:url) { UrlGenerator.instance.profile_url user }

  it do
    is_expected.to eq(
      "[url=#{url} b-mention]<s>@</s>#{user.nickname}[/url], test"
    )
  end

  context 'with text' do
    let(:text) { "[user=#{user.id}], test[/user]" }

    it do
      is_expected.to eq(
        "[url=#{url} b-mention]<s>@</s>, test[/url]"
      )
    end
  end

  context 'non existing user' do
    let(:user) { build_stubbed :user }

    it do
      is_expected.to eq(
        "<span class='b-mention b-entry-404'><s>@</s>" \
          "<del>[user=#{user.id}]</del></span>, test"
      )
    end
  end
end
