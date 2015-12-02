describe ContestsController do
  include_context :seeds
  include_context :authenticated, :admin

  let(:contest) { create :contest, user: user }

  describe '#index' do
    before { get :index }
    it { expect(response).to have_http_status :success }
  end

  describe '#grid' do
    let(:user) { create :user, :user }

    context 'created' do
      let(:contest) { create :contest, user: user }
      before { get :grid, id: contest.to_param }

      it { expect(response).to redirect_to contests_url }
    end

    context 'proposing' do
      let(:contest) { create :contest, :proposing, user: user }
      before { get :grid, id: contest.to_param }

      it { expect(response).to redirect_to contest_url(contest) }
    end

    context 'started' do
      let(:contest) { create :contest, :with_5_members, user: user }
      before { contest.start! }
      before { get :grid, id: contest.to_param }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#show' do
    let(:user) { create :user, :user }
    let(:contest) { create :contest, :with_5_members, :with_thread, user: user }

    context 'started' do
      before { contest.start! }

      context 'w/o round' do
        before { get :show, id: contest.to_param }
        it { expect(response).to have_http_status :success }
      end

      context 'with round' do
        before { get :show, id: contest.to_param, round: 1 }
        it { expect(response).to have_http_status :success }
      end
    end

    context 'finished' do
      before do
        contest.start!
        contest.rounds.each do |round|
          contest.current_round.matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday }
          contest.progress!
          contest.reload
        end

        get :show, id: contest.to_param
      end
      it { expect(response).to have_http_status :success }
    end

    context 'proposing' do
      let(:contest) { create :contest, :with_generated_thread, :proposing, user: user }
      before { get :show, id: contest.to_param }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#users' do
    let(:user) { create :user, :user }
    let(:contest) { create :contest, :with_5_members, user: user }
    let(:make_request) { get :users, id: contest.to_param, round: 1, match_id: contest.rounds.first.matches.first.id }
    before { contest.start }

    context 'not finished' do
      before { make_request }
      it { expect(response).to redirect_to contest_url(contest) }
    end

    context 'finished' do
      let!(:contest_user_vote) { create :contest_user_vote, match: contest.current_round.matches.first, user: user, item_id: contest.current_round.matches.first.left_id, ip: '1.1.1.1' }
      before do
        contest.current_round.matches.update_all started_on: Date.yesterday, finished_on: Date.yesterday
        contest.current_round.reload
        contest.current_round.finish!
      end
      before { make_request }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#comments' do
    let!(:contest) { create :contest, :with_thread, user: user }
    before { contest.send :generate_thread }
    let!(:comment) { create :comment, commentable: contest.thread }
    before { get :comments, id: contest.to_param }

    it { expect(response).to redirect_to section_topic_url(id: contest.thread, section: contests_section) }
  end

  describe '#new' do
    before { get :new }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    before { get :edit, id: contest.to_param }
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
        patch :update, id: contest.id, contest: attr.merge(description: 'zxc')
      end

      it { expect(response).to redirect_to edit_contest_url(assigns :resource) }
      it { expect(resource.description).to eq 'zxc' }
      it { expect(resource.errors).to be_empty }
    end

    context 'when validation errors' do
      before { patch 'update', id: contest.id, contest: { title: '' } }

      it { expect(response).to have_http_status :success }
      it { expect(resource.errors).to_not be_empty }
    end
  end

  describe '#create' do
    context 'when success' do
      before { post :create, contest: contest.attributes.except('id', 'user_id', 'state', 'created_at', 'updated_at', 'permalink', 'finished_on') }
      it { expect(response).to redirect_to edit_contest_url(resource) }
    end

    context 'when validation errors' do
      before { post :create, contest: { id: 1 } }

      it { expect(response).to have_http_status :success }
      it { expect(resource.new_record?).to be true }
    end
  end

  describe '#start' do
    let(:contest) { create :contest, :with_5_members, user: user }
    before { post :start, id: contest.to_param }

    it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    it { expect(resource.started?).to be true }
  end

  describe '#propose' do
    let(:contest) { create :contest, user: user }
    before { post :propose, id: contest.to_param }

    it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    it { expect(resource.proposing?).to be true }
  end

  describe '#cleanup_suggestions' do
    let(:contest) { create :contest, :proposing, user: user }
    let!(:contest_suggestion_1) { create :contest_suggestion, contest: contest, user: user }
    let!(:contest_suggestion_2) { create :contest_suggestion, contest: contest, user: create(:user, id: 2, sign_in_count: 999) }
    before { post :cleanup_suggestions, id: contest.to_param }

    #it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    it { expect(resource.suggestions.size).to eq(1) }
  end

  describe '#stop_propose' do
    let(:contest) { create :contest, state: :proposing, user: user }
    before { post :stop_propose, id: contest.to_param }

    it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    it { expect(resource.created?).to be true }
  end

  #describe '#finish' do
    #let(:contest) { create :contest, :with_5_members, user: user }
    #before do
      #contest.start
      #get 'finish', id: contest.to_param
    #end

    #it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    #it { expect(resource.state).to eq 'finished' }
  #end

  describe '#build' do
    let(:contest) { create :contest,:with_5_members, user: user }
    before { post :build, id: contest.to_param }

    it { expect(response).to redirect_to edit_contest_url(id: resource.to_param) }
    it { expect(resource.rounds.size).to eq(6) }
  end
end
