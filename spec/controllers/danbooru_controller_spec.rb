require 'spec_helper'

#TODO: разобраться почему DelayedJob не работает и включить его в тесты
describe DanbooruController do
  describe :show do
    let(:md5) { 'TTTEST' }
    let(:url) { "http://hijiribe.donmai.us/data/#{md5}.jpg" }
    let(:tmp_path) { Rails.root.join('public', 'images', DanbooruController::TmpImagesDir, "#{md5}.jpg") }

    before do
      stub_request(:any, url).to_return({body: url}, {body: 'another response'})
      $redis.stub(:get).and_return(false)
    end
    after { File.delete(tmp_path) if File.exists?(tmp_path) }

    it 'should raise forbidden for not allowed urls' do
      get :show, url: Base64.encode64('http://lenta.ru/image.jpg'), md5: md5
      response.should be_forbidden
    end

    it 'should download new image to tmp file' do
      get :show, url: Base64.encode64(url), md5: md5

      File.exists?(tmp_path).should be_true
      open(tmp_path).read.should == url
    end

    it 'should download new image only once' do
      get :show, url: Base64.encode64(url), md5: md5
      get :show, url: Base64.encode64(url), md5: md5

      open(tmp_path).read.should == url
    end

    it 'should redirect to s3 if entry exists in redis' do
      $redis.stub(:get).and_return(true)

      get :show, url: Base64.encode64(url), md5: md5
      response.should redirect_to(DanbooruController.s3_path(DanbooruController.filename(md5)))
    end
  end

  describe :yandere do
    let(:url) { 'https://yande.re/post/index.json?page=1&limit=100&tags=kaichou_wa_maid-sama!' }
    let(:data) { { 'url' => url, 'test' => 'test' } }
    before { stub_request(:any, url).to_return body: data.to_json }

    it 'should raise forbidden for not allowed urls' do
      get :yandere, url: Base64.encode64('http://lenta.ru/image.jpg')
      response.should be_forbidden
    end

    it 'should render json' do
      get :yandere, url: Base64.encode64(url)
      JSON.parse(response.body).should eq data
    end
  end
end
