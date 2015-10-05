describe Api::V1::ConstantsController, :show_in_doc do
  describe '#anime' do
    before { get :anime }
    it { expect(response).to have_http_status :success }
  end

  describe '#manga' do
    before { get :manga }
    it { expect(response).to have_http_status :success }
  end

  describe '#user_rate' do
    before { get :user_rate }
    it { expect(response).to have_http_status :success }
  end

  describe '#club' do
    before { get :club }
    it { expect(response).to have_http_status :success }
  end

  describe '#smileys' do
    before { get :smileys }
    it { expect(response).to have_http_status :success }
  end
end
