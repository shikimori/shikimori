describe RedirectsController do
  describe '#show' do
    subject! { get :show, params: { url: url } }

    context 'has url' do
      let(:url) { 'https://ya.ru' }
      it { is_expected.to redirect_to url }
    end

    context 'no url' do
      let(:url) { '' }
      it { is_expected.to redirect_to root_url }
    end
  end
end
