describe RanobeController do
  let(:ranobe) { create :ranobe }
  include_examples :db_entry_controller, :ranobe

  describe '#show' do
    let(:ranobe) { create :ranobe, :with_topics }

    describe 'id' do
      before { get :show, params: { id: ranobe.id } }
      it { expect(response).to redirect_to ranobe_url(ranobe) }
    end

    describe 'to_param' do
      before { get :show, params: { id: ranobe.to_param } }
      it { expect(response).to have_http_status :success }
    end

    describe 'not ranobe' do
      let(:ranobe) { create :manga }
      let(:make_request) { get :show, params: { id: ranobe.to_param } }
      it { expect { make_request }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
