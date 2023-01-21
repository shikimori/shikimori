describe Users::PollsController do
  include_context :authenticated, :user

  describe '#index' do
    let!(:poll_1) { create :poll, user: user }
    let!(:poll_2) { create :poll, user: user }
    let!(:poll_3) { create :poll, user: user_2 }

    subject! { get :index, params: { profile_id: user.to_param } }

    it do
      expect(collection).to eq [poll_2, poll_1]
      expect(response).to have_http_status :success
    end
  end

  describe '#show' do
    let(:poll) { create :poll, state, user: user }
    subject! { get :show, params: { profile_id: user.to_param, id: poll.id } }

    context 'pending' do
      let(:state) { :pending }
      it { expect(response).to redirect_to edit_profile_poll_url(user, poll) }
    end

    context 'started & stopped' do
      let(:state) { %i[started stopped].sample }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    subject! do
      get :new,
        params: {
          profile_id: user.to_param,
          poll: { user_id: user.id }
        }
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#create' do
    subject! do
      post :create,
        params: {
          profile_id: user.to_param,
          poll: {
            user_id: user.id,
            name: 'test',
            text: 'zxc',
            width: 'limited',
            variants_attributes: [{
              label: 'test 1'
            }, {
              label: 'test 2'
            }, {
              label: ''
            }, {
              label: 'test 1'
            }]
          }
        }
    end

    it do
      expect(resource).to have_attributes(
        name: 'test',
        text: 'zxc',
        state: 'pending',
        width: 'limited',
        user_id: user.id
      )
      expect(resource.variants).to have(2).items
      expect(resource.variants[0]).to have_attributes(label: 'test 1')
      expect(resource.variants[1]).to have_attributes(label: 'test 2')
      expect(resource).to be_valid
      expect(response).to redirect_to edit_profile_poll_url(user, resource)
    end
  end

  describe '#edit' do
    let(:poll) { create :poll, :pending, user: user }
    subject! { get :edit, params: { profile_id: user.to_param, id: poll.id } }

    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    let(:poll) { create :poll, poll_state, user: user, name: 'qqq', text: 'cc' }
    let!(:poll_variant) { create :poll_variant, poll: poll, label: 'zzz' }

    subject! do
      post :update,
        params: {
          profile_id: user.to_param,
          id: poll.id,
          poll: {
            name: 'test',
            text: 'zxc',
            width: 'limited',
            variants_attributes: [{
              label: 'test 1'
            }, {
              label: 'test 2'
            }]
          }
        }
    end

    context 'pending' do
      let(:poll_state) { :pending }
      it do
        expect(resource).to be_persisted
        expect(resource).to_not be_changed
        expect(resource).to be_valid
        expect(resource).to have_attributes(
          name: 'test',
          text: 'zxc',
          state: 'pending',
          user_id: user.id
        )
        expect(resource.variants).to have(2).items
        expect(resource.variants[0]).to have_attributes(label: 'test 1')
        expect(resource.variants[1]).to have_attributes(label: 'test 2')

        expect { poll_variant.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(response).to redirect_to edit_profile_poll_url(user, resource)
      end
    end

    context 'started' do
      let(:poll_state) { :started }

      it do
        expect(resource).to be_persisted
        expect(resource).to_not be_changed
        expect(resource).to be_valid
        expect(resource).to have_attributes(
          name: 'test',
          text: 'zxc',
          state: 'started',
          user_id: user.id
        )
        expect(resource.variants).to have(1).items
        expect(resource.variants[0]).to eq poll_variant.reload

        expect(response).to redirect_to profile_poll_url(user, resource)
      end
    end
  end

  describe '#start' do
    let(:poll) { create :poll, :pending, :with_variants, user: user }
    subject! { post :start, params: { profile_id: user.to_param, id: poll.id } }

    it do
      expect(resource.reload).to be_started
      expect(response).to redirect_to profile_poll_url(user, resource)
    end
  end

  describe '#stop' do
    let(:poll) { create :poll, :started, user: user }

    subject! { post :stop, params: { profile_id: user.to_param, id: poll.id } }

    it do
      expect(resource.reload).to be_stopped
      expect(response).to redirect_to profile_poll_url(user, resource)
    end
  end

  describe '#destroy' do
    let(:poll) { create :poll, user: user }

    subject! do
      delete :destroy,
        params: {
          profile_id: user.to_param,
          id: poll.id
        }
    end

    it do
      expect(resource).to be_destroyed
      expect(response).to redirect_to profile_polls_url(user)
    end
  end
end
