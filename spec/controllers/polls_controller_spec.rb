describe PollsController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:poll_1) { create :poll, user: user }
    let!(:poll_2) { create :poll, user: user }

    before { get :index }

    it do
      expect(collection).to eq [poll_2, poll_1]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let(:poll) { create :poll, state, user: user }
    before { get :show, params: { id: poll.id } }

    context 'pending' do
      let(:state) { :pending }
      it { expect(response).to redirect_to edit_poll_url(poll) }
    end

    context 'started & stopped' do
      let(:state) { %i[started stopped].sample }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    before do
      get :new,
        params: {
          poll: { user_id: user.id }
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    before do
      post :create,
        params: {
          poll: {
            user_id: user.id,
            name: 'test',
            poll_variants_attributes: [{
              text: 'test 1'
            }, {
              text: 'test 2'
            }, {
              text: ''
            }, {
              text: 'test 1'
            }]
          }
        }
    end

    it do
      expect(resource).to have_attributes(
        name: 'test',
        state: 'pending',
        user_id: user.id
      )
      expect(resource.poll_variants).to have(2).items
      expect(resource.poll_variants[0]).to have_attributes(text: 'test 1')
      expect(resource.poll_variants[1]).to have_attributes(text: 'test 2')
      expect(resource).to be_valid
      expect(response).to redirect_to edit_poll_url(resource)
    end
  end

  describe '#edit' do
    let(:poll) { create :poll, :pending, user: user }
    before { get :edit, params: { id: poll.id } }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:poll) { create :poll, user: user }
    let!(:poll_variant) { create :poll_variant, poll: poll, text: 'zzz' }

    before do
      post :update,
        params: {
          id: poll.id,
          poll: {
            name: 'test',
            poll_variants_attributes: [{
              text: 'test 1'
            }, {
              text: 'test 2'
            }]
          }
        }
    end

    it do
      expect(resource).to have_attributes(
        name: 'test',
        state: 'pending',
        user_id: user.id
      )
      expect(resource.poll_variants).to have(2).items
      expect(resource.poll_variants[0]).to have_attributes(text: 'test 1')
      expect(resource.poll_variants[1]).to have_attributes(text: 'test 2')

      expect { poll_variant.reload }.to raise_error ActiveRecord::RecordNotFound

      expect(resource).to be_valid
      expect(response).to redirect_to edit_poll_url(resource)
    end
  end

  describe '#start' do
    let(:poll) { create :poll, :pending, :with_variants, user: user }
    before { post :start, params: { id: poll.id } }

    it do
      expect(resource.reload).to be_started
      expect(response).to redirect_to poll_url(resource)
    end
  end

  describe '#stop' do
    let(:poll) { create :poll, :started, user: user }

    before { post :stop, params: { id: poll.id } }

    it do
      expect(resource.reload).to be_stopped
      expect(response).to redirect_to poll_url(resource)
    end
  end

  describe '#destroy' do
    let(:poll) { create :poll, user: user }

    before { delete :destroy, params: { id: poll.id } }

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to polls_url
    end
  end
end
