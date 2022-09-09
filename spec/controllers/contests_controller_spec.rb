describe ContestsController do
  include_context :authenticated, :admin

  let(:contest) { create :contest, user: user }

  describe '#index' do
    subject! { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#grid' do
    context 'created' do
      let(:contest) { create :contest, user: user }
      subject! { get :grid, params: { id: contest.to_param } }

      it { expect(response).to redirect_to contests_url }
    end

    context 'proposing' do
      let(:contest) { create :contest, :proposing, user: user }
      subject! { get :grid, params: { id: contest.to_param } }

      it { expect(response).to redirect_to contest_url(contest) }
    end

    context 'started' do
      let(:contest) { create :contest, :with_5_members, user: user }
      before { Contest::Start.call contest }
      subject! { get :grid, params: { id: contest.to_param } }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    let(:contest) { create :contest, :with_5_members, :with_topics, user: user }

    context 'started' do
      before { Contest::Start.call contest }

      context 'w/o round' do
        subject! { get :show, params: { id: contest.to_param } }
        it { expect(response).to have_http_status :success }
      end

      context 'with round' do
        subject! { get :show, params: { id: contest.to_param, round: 1 } }
        it { expect(response).to have_http_status :success }
      end
    end

    context 'finished' do
      before do
        Contest::Start.call contest
        contest.rounds.each do
          contest.current_round.matches.each do |contest_match|
            contest_match.update(
              started_on: Time.zone.yesterday,
              finished_on: Time.zone.yesterday
            )
          end
          Contest::Progress.call contest
          contest.reload
        end

        get :show, params: { id: contest.to_param }
      end
      it { expect(response).to have_http_status :success }
    end

    context 'proposing' do
      let(:contest) { create :contest, :with_topics, :proposing, user: user }
      subject! { get :show, params: { id: contest.to_param } }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    subject! { get :new }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    subject! { get :edit, params: { id: contest.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#update' do
    context 'when success' do
      let :attr do
        contest.attributes.except(
          'id', 'user_id', 'state', 'created_at',
          'updated_at', 'permalink', 'finished_on'
        )
      end
      before do
        patch :update, params: { id: contest.id, contest: attr }
      end

      it do
        expect(resource.errors).to be_empty
        expect(response).to redirect_to edit_contest_url(resource)
      end
    end

    context 'when validation errors' do
      before do
        patch 'update', params: {
          id: contest.id, contest: { title_ru: '', title_en: '' }
        }
      end

      it do
        expect(resource.errors).to_not be_empty
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#create' do
    context 'when success' do
      subject! do
        post :create,
          params: {
            contest: contest.attributes.except(
              'id', 'user_id', 'state', 'created_at', 'updated_at',
              'permalink', 'finished_on'
            )
          }
      end
      it { expect(response).to redirect_to edit_contest_url(resource) }
    end

    context 'when validation errors' do
      subject! { post :create, params: { contest: { id: 1 } } }

      it do
        expect(resource).to be_new_record
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#start' do
    let(:contest) { create :contest, :with_5_members, user: user }
    subject! { post :start, params: { id: contest.to_param } }

    it do
      expect(resource).to be_started
      expect(response).to redirect_to edit_contest_url(id: resource.to_param)
    end
  end

  describe '#propose' do
    let(:contest) { create :contest, user: user }
    subject! { post :propose, params: { id: contest.to_param } }

    it do
      expect(resource).to be_proposing
      expect(response).to redirect_to edit_contest_url(id: resource.to_param)
    end
  end

  describe '#cleanup_suggestions' do
    let(:contest) { create :contest, :proposing, user: user }
    before { allow(Contest::CleanupSuggestions).to receive :call }

    subject! { post :cleanup_suggestions, params: { id: contest.to_param } }

    it do
      expect(Contest::CleanupSuggestions).to have_received(:call).with contest
      expect(response).to redirect_to edit_contest_url(id: resource.to_param)
    end
  end

  describe '#stop_propose' do
    let(:contest) { create :contest, state: :proposing, user: user }
    subject! { post :stop_propose, params: { id: contest.to_param } }

    it do
      expect(resource).to be_created
      expect(response).to redirect_to edit_contest_url(id: resource.to_param)
    end
  end

  describe '#build' do
    let(:contest) { create :contest, :with_5_members, user: user }
    subject! { post :build, params: { id: contest.to_param } }

    it do
      expect(resource.rounds).to have(6).items
      expect(response).to redirect_to edit_contest_url(id: resource.to_param)
    end
  end
end
