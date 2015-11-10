describe AnimeVideoUrlValidator, type: :validator do
  class ValidatorTest
    include ActiveModel::Model
    attr_accessor :anime_id
    attr_accessor :url
    validates :url, anime_video_url: true
  end

  subject { ValidatorTest.new url: url, anime_id: anime_id }
  let(:url) {}
  let(:anime_id) {}
  let!(:other_anime_video) {}
  before { subject.valid? }

  context 'valid' do
    it { is_expected.to allow_value('http://foo.com').for :url }
    it { is_expected.to allow_value('https://foo.com').for :url }
  end

  context 'invalid' do
    let(:message) { subject.errors[:url].first }

    context 'not url' do
      it { is_expected.to_not allow_value('123').for :url }
      it { expect(message).to eq I18n.t('activerecord.errors.messages.invalid') }
    end
  end

  context 'uniqueness' do
    let(:other_anime_video) { create :anime_video, anime: anime, url: other_url }
    let(:anime) { build_stubbed :anime }
    let(:link) { 'foo.com/video/1' }
    let(:other_url) { "http://#{link}" }

    context 'other url' do
      it { is_expected.to allow_value(other_url + '0').for :url }
    end

    context 'other anime_id' do
      let(:anime_id) { anime.id + 1 }
      it { is_expected.to allow_value(other_url).for :url }
    end

    context 'eq url' do
      let(:anime_id) { anime.id }
      it { is_expected.to_not allow_value(other_url).for :url }
      it { is_expected.to_not allow_value("https://#{link}").for :url }

      context 'check messages' do
        let(:url) { other_url }
        let(:message) { subject.errors[:url].first }
        it { expect(message).to eq I18n.t('activerecord.errors.models.videos.attributes.url.taken') }
      end
    end
  end
end
