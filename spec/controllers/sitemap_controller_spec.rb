describe SitemapController do
  subject! { get :index, format: }

  context 'html' do
    let(:format) { :html }
    it { expect(response).to have_http_status :success }
  end

  context 'xml' do
    let(:format) { :xml }
    it { expect(response).to have_http_status :success }
  end
end
