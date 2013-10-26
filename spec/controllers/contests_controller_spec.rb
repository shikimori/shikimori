require 'spec_helper'

describe ContestsController do
  let(:user) { create :user, id: 1 }
  before { sign_in user }

  let(:contest) { create :contest }

  describe :index do
    before { get :index }
    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :grid do
    context :created do
      let(:contest) { create :contest }
      before { get :grid, id: contest.to_param }

      it { should respond_with :redirect }
      it { should redirect_to contests_url }
    end

    context :proposing do
      let(:contest) { create :contest, state: 'proposing' }
      before { get :grid, id: contest.to_param }

      it { should respond_with :redirect }
      it { should redirect_to contest_url(contest) }
    end

    context :started do
      let(:contest) { create :contest_with_5_members }
      before { contest.start! }
      before { get :grid, id: contest.to_param }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end

  describe :show do
    let(:contest) { create :contest_with_5_members }
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
      let(:contest) { create :contest, state: 'proposing' }
      before { get :show, id: contest.to_param }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end

  describe :users do
    let(:contest) { create :contest_with_5_members }
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

  describe :new do
    before { get :new }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :edit do
    before { get :edit, id: contest.id }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :update do
    context 'when success' do
      before { put :update, id: contest.id, contest: contest.attributes.except('id', 'user_id', 'state', 'created_at', 'updated_at', 'permalink', 'finished_on').merge(description: 'zxc') }

      it { should respond_with 302 }
      it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
      it { assigns(:contest).description.should eq 'zxc' }
      it { assigns(:contest).errors.should be_empty }
    end

    context 'when validation errors' do
      before { put 'update', id: contest.id, contest: { title: '' } }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
      it { assigns(:contest).errors.should_not be_empty }
    end
  end

  describe :create do
    context 'when success' do
      before { post :create, contest: contest.attributes.except('id', 'user_id', 'state', 'created_at', 'updated_at', 'permalink', 'finished_on') }

      it { should respond_with :redirect }
      it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
      it { assigns(:contest).persisted?.should be_true }
    end

    context 'when validation errors' do
      before { post :create, contest: {} }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
      it { assigns(:contest).new_record?.should be_true }
    end
  end

  describe :start do
    let(:contest) { create :contest_with_5_members }
    before { get :start, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { assigns(:contest).started?.should be_true }
  end

  describe :propose do
    let(:contest) { create :contest }
    before { get :propose, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { assigns(:contest).proposing?.should be_true }
  end

  #describe :finish do
    #let(:contest) { create :contest_with_5_members }
    #before do
      #contest.start
      #get 'finish', id: contest.id
    #end

    #it { should respond_with 302 }
    #it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    #it { assigns(:contest).state.should eq 'finished' }
  #end

  describe :build do
    let(:contest) { create :contest_with_5_members }
    before { get :build, id: contest.id }

    it { should respond_with 302 }
    it { should redirect_to edit_contest_url(id: assigns(:contest).to_param) }
    it { assigns(:contest).rounds.should have(6).items }
  end
end
