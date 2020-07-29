describe BbCodes::Tags::VideoTag do
  subject { described_class.instance.format text }

  let(:hash) { 'hGgCnkvHLJY' }
  let(:video) { create :video, url: "http://www.youtube.com/watch?v=#{hash}" }
  let(:text) { "[video=#{video.id}]" }

  it do
    is_expected.to include(
      "data-href=\"//youtube.com/embed/#{hash}\" href=\"https://youtube.com/watch?v=#{hash}\""
    )
  end
end
