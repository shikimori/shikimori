describe PollsController do
  include_context :authenticated, :user

  describe '#show' do
    let(:poll) { create :poll, user: user }
    before { get :show, params: { id: poll.id } }

    it { expect(response).to have_http_status :success }
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
        user_id: user.id,
        state: 'pending'
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
        user_id: user.id,
        state: 'pending'
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
  end

  describe '#stop' do
  end
end
