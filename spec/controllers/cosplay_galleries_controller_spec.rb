describe CosplayGalleriesController do
  include_context :seeds
  include_context :authenticated, :admin

  describe '#publishing' do
    before { get :publishing }
    it { expect(response).to have_http_status :success }
  end

  describe '#publish' do
    let!(:cosplayer) { create :user, :cosplayer }
    let(:cosplay_gallery) { create :cosplay_gallery, :anime }
    before { post :publish, id: cosplay_gallery.id }

    it do
      expect(response).to redirect_to(
        UrlGenerator.instance.topic_url(cosplay_gallery.topic)
      )
    end
  end
end
