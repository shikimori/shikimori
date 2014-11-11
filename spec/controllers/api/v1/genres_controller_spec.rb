describe Api::V1::GenresController, :type => :controller do
  describe :show do
    let!(:genre) { create :genre }
    before { get :index, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
