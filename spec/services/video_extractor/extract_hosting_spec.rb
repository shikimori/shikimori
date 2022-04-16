describe VideoExtractor::ExtractHosting do
  let(:service) { VideoExtractor::ExtractHosting.new url }

  subject! { service.call }

  context 'valid url' do
    let(:url) { attributes_for(:anime_video)[:url] }
    it { is_expected.to eq 'vk.com' }
  end

  context 'remove www' do
    let(:url) { 'http://www.vk.com?id=1' }
    it { is_expected.to eq 'vk.com' }
  end

  context 'second level domain' do
    let(:url) { 'http://www.foo.bar.com/video?id=1' }
    it { is_expected.to eq 'bar.com' }
  end

  context 'aliased vk.com' do
    let(:url) { 'http://vkontakte.ru/video?id=1' }
    it { is_expected.to eq 'vk.com' }
  end

  context 'aliased mail.ru' do
    let(:url) { 'http://mailru.ru' }
    it { is_expected.to eq 'mail.ru' }
  end
end
