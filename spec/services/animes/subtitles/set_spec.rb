describe Animes::Subtitles::Set do
  subject! { described_class.call anime, subtitles }

  let(:anime) { build_stubbed :anime }
  let(:subtitles) { 'zxc' }

  it { expect(Animes::Subtitles::Get.call(anime)).to eq subtitles }
end
