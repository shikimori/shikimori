describe BbCodes::Tags::ReviewTag do
  subject { described_class.instance.format text }

  let(:text) { "[review=#{review.id}], test" }
  let(:url) { UrlGenerator.instance.review_url review.reload }
  let(:review) { create :review, user: user, anime: anime }
  let(:anime) { create :anime }

  let(:attrs) do
    {
      id: review.id,
      type: :review,
      userId: review.user_id,
      text: user.nickname
    }
  end

  it do
    is_expected.to eq(
      <<~HTML.squish
        <a href='#{url}' class='b-mention bubbled'
          data-attrs='#{ERB::Util.h attrs.to_json}'><s>@</s><span>#{user.nickname}</span></a>, test
      HTML
    )
  end

  context 'non existing review', :url do
    let(:review) { build_stubbed :review }
    let(:attrs) { { id: review.id, type: :review } }
    let(:url) { UrlGenerator.instance.review_url review.id }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a href='#{url}' class='b-mention b-entry-404 bubbled'
            data-attrs='#{ERB::Util.h attrs.to_json}'><s>@</s><del>[review=#{review.id}]</del></a>, test
        HTML
      )
    end
  end
end
