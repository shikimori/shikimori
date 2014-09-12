require 'spec_helper'
require 'cancan/matchers'

describe ContestsController do
  let(:user) { create :user, id: 1 }
  before { sign_in user }

  let(:contest) { create :contest, user: user }

  describe '#index' do
    before { get :index }
    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe '#grid' do
    context :created do
      let(:contest) { create :contest, user: user }
      before { get :grid, id: contest.to_param }

      it { should respond_with :redirect }
      it { should redirect_to contests_url }
    end

    context :proposing do
      let(:contest) { create :contest, user: user, state: 'proposing' }
      before { get :grid, id: contest.to_param }

      it { should respond_with :redirect }
      it { should redirect_to contest_url(contest) }
    end

    context :started do
      let(:contest) { create :contest_with_5_members, user: user }
      before { contest.start! }
      before { get :grid, id: contest.to_param }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end

  describe '#show' do
    let(:contest) { create :contest_with_5_members, user: user }
    before { contest.start! if contest.can_start? }

    context 'w/o round' do
      before { get :show, id: contest.to_param }
      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end

    context 'with round' do
      before { get :show, id: contest.to_param, round: 1 }
      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end

    context :finished do
      before do
        contest.rounds.each do |round|
          contest.current_round.matches.each { |v| v.update_attributes started_on: Date.yesterday, finished_on: Date.yesterday }
          contest.process!
          contest.reload
        end

        get :show, id: contest.to_param
      end
      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end

    context :proposing do
      let(:contest) { create :contest, state: 'proposing', user: user }
      before { get :show, id: contest.to_param }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end

  describe '#users' do
    let(:contest) { create :contest_with_5_members, user: user }
    before { contest.start }

    describe 'not finished' do
      it 'it raises not found error' do
        expect { get 'users', id: contest.id, round: 1, match_id: contest.rounds.first.matches.first.id }
      end
    end

    describe 'finished' do
      before do
        contest.current_round.matches.update_all started_on: Date.yesterday, finished_on: Date.yesterday
        contest.current_round.reload
        contest.current_round.finish!
        get :users, id: contest.id, round: 1, match_id: contest.rounds.first.matches.first.id
      end
      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end

  describe '#new' do
    before { get :new }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe '#edit' do
    before { get :edit, id: contest.id }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :update do
    context 'when success' do
      before { patch :update, id: contest.id, contest: contest.attributes.except('id', 'user_id', 'state', 'created_at', 'updated_at', 'permalink', 'finished_on').merge(description: 'zxc') }

      it { should respond_with 302 }
      it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
      it { expect(assigns(:contest).description).to eq 'zxc' }
      it { expect(assigns(:contest).errors).to be_empty }
    end

    context 'when validation errors' do
      before { patch 'update', id: contest.id, contest: { title: '' } }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
      it { expect(assigns(:contest).errors).to_not be_empty }
    end
  end

  describe '#create' do
    context 'when success' do
      before { post :create, contest: contest.attributes.except('id', 'user_id', 'state', 'created_at', 'updated_at', 'permalink', 'finished_on') }

      it { should respond_with :redirect }
      it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
      it { expect(assigns :contest).to be_persisted }
    end

    context 'when validation errors' do
      before { post :create, contest: { id: 1 } }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
      it { expect(assigns(:contest).new_record?).to be true }
    end
  end

  describe '#start' do
    let(:contest) { create :contest_with_5_members, user: user }
    before { post :start, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { expect(assigns(:contest).started?).to be true }
  end

  describe '#propose' do
    let(:contest) { create :contest, user: user }
    before { post :propose, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { expect(assigns(:contest).proposing?).to be true }
  end

  describe '#cleanup_suggestions' do
    let(:contest) { create :contest, :proposing, user: user }
    let!(:contest_suggestion_1) { create :contest_suggestion, contest: contest, user: user }
    let!(:contest_suggestion_2) { create :contest_suggestion, contest: contest, user: create(:user, id: 2, sign_in_count: 999) }
    before { post :cleanup_suggestions, id: contest.id }

    #it { should respond_with 302 }
    #it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { expect(assigns(:contest).suggestions).to have(1).item }
  end

  describe '#stop_propose' do
    let(:contest) { create :contest, state: :proposing, user: user }
    before { post :stop_propose, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { expect(assigns(:contest).created?).to be true }
  end

  #describe '#finish' do
    #let(:contest) { create :contest_with_5_members, user: user }
    #before do
      #contest.start
      #get 'finish', id: contest.id
    #end

    #it { should respond_with 302 }
    #it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    #it { expect(assigns(:contest).state).to eq 'finished' }
  #end

  describe '#build' do
    let(:contest) { create :contest_with_5_members, user: user }
    before { post :build, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { expect(assigns(:contest).rounds).to have(6).items }
  end

  describe :permissions do
    context :contests_moderator do
      subject { Ability.new build_stubbed(:user, :contests_moderator) }
      it { should be_able_to :manage, contest }
    end

    context :guest do
      subject { Ability.new nil }
      it { should be_able_to :read, contest }
      it { should_not be_able_to :manage, contest }
    end

    context :user do
      subject { Ability.new build_stubbed(:user) }
      it { should be_able_to :read, contest }
      it { should_not be_able_to :manage, contest }
    end
  end
end
