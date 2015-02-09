require 'webmock/rspec'

describe DanbooruController do
  describe '#show' do
    let(:md5) { 'TTTEST' }
    let(:url) { "http://hijiribe.donmai.us/data/#{md5}.jpg" }
    let(:tmp_path) { Rails.root.join('public', 'images', DanbooruController::TmpImagesDir, "#{md5}.jpg") }

    before do
      stub_request(:any, url).to_return({body: url}, {body: 'another response'})
      allow($redis).to receive(:get).and_return(false)
    end
    after { File.delete(tmp_path) if File.exists?(tmp_path) }

    it 'should raise forbidden for not allowed urls' do
      get :show, url: Base64.encode64('http://lenta.ru/image.jpg'), md5: md5
      expect(response).to be_forbidden
    end

    it 'should download new image to tmp file' do
      get :show, url: Base64.encode64(url), md5: md5

      expect(File.exists?(tmp_path)).to be_truthy
      expect(open(tmp_path).read).to eq(url)
    end

    it 'should download new image only once' do
      get :show, url: Base64.encode64(url), md5: md5
      get :show, url: Base64.encode64(url), md5: md5

      expect(open(tmp_path).read).to eq(url)
    end

    it 'should redirect to s3 if entry exists in redis' do
      allow($redis).to receive(:get).and_return(true)

      get :show, url: Base64.encode64(url), md5: md5
      expect(response).to redirect_to(DanbooruController.s3_path(DanbooruController.filename(md5)))
    end
  end

  describe '#yandere' do
    let(:url) { 'https://yande.re/post/index.json?page=1&limit=100&tags=kaichou_wa_maid-sama!' }
    let(:data) { { 'url' => url, 'test' => 'test' } }
    before { stub_request(:any, url).to_return body: data.to_json }

    it 'should raise forbidden for not allowed urls' do
      get :yandere, url: Base64.encode64('http://lenta.ru/image.jpg').strip
      expect(response).to be_forbidden
    end

    it 'should render json' do
      get :yandere, url: URI.encode(Base64.encode64(url).strip)
      expect(JSON.parse(response.body)).to eq data
    end
  end
end
