require 'spec_helper'
require 'cancan/matchers'

describe Api::V1::UserRatesController do
  include_context :authenticated

  describe :edit do
    let(:user_rate) { create :user_rate, user: user }
    before { get :edit, id: user_rate.id }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :create do
    let(:target) { create :anime }
    let(:create_params) {{ user_id: user.id, target_id: target.id, target_type: target.class.name, score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
    before { post :create, user_rate: create_params, format: :json }

    it { should respond_with :created }

    describe :user_rate do
      subject { assigns :user_rate }

      its(:user_id) { should eq create_params[:user_id] }
      its(:target_id) { should eq create_params[:target_id] }
      its(:target_type) { should eq create_params[:target_type] }
      its(:score) { should eq create_params[:score] }
      its([:status]) { should eq create_params[:status] }
      its(:episodes) { should eq create_params[:episodes] }
      its(:volumes) { should eq create_params[:volumes] }
      its(:chapters) { should eq create_params[:chapters] }
      its(:text) { should eq create_params[:text] }
      its(:rewatches) { should eq create_params[:rewatches] }
    end
  end

  describe :update do
    let(:user_rate) { create :user_rate, user: user }
    let(:update_params) {{ score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
    before { patch :update, id: user_rate.id, user_rate: update_params, format: :json }

    it { should respond_with :success }

    describe :user_rate do
      subject { assigns :user_rate }

      its(:score) { should eq update_params[:score] }
      its([:status]) { should eq update_params[:status] }
      its(:episodes) { should eq update_params[:episodes] }
      its(:volumes) { should eq update_params[:volumes] }
      its(:chapters) { should eq update_params[:chapters] }
      its(:text) { should eq update_params[:text] }
      its(:rewatches) { should eq update_params[:rewatches] }
    end
  end

  describe :increment do
    let(:user_rate) { create :user_rate, user: user, episodes: 1 }
    before { post :increment, id: user_rate.id, format: :json }

    it { should respond_with :created }

    describe :user_rate do
      subject { assigns :user_rate }

      its(:episodes) { should eq user_rate.episodes + 1 }
    end
  end

  describe :destroy do
    let(:user_rate) { create :user_rate, user: user }
    before { delete :destroy, id: user_rate.id, format: :json }

    it { should respond_with :no_content }
    it { expect(assigns(:user_rate)).to be_new_record }
  end

  describe :cleanup do
    let!(:user_rate) { create :user_rate, user: user, target: entry }
    let!(:user_history) { create :user_history, user: user, target: entry }

    context :anime do
      let(:entry) { create :anime }
      before { post :cleanup, type: :anime }

      it { should respond_with :success }
      it { expect(user.anime_rates).to be_empty }
      it { expect(user.history).to be_empty }
    end

    context :manga do
      let(:entry) { create :manga }
      before { post :cleanup, type: :manga }

      it { should respond_with :success }
      it { expect(user.manga_rates).to be_empty }
      it { expect(user.history).to be_empty }
    end
  end

  describe :reset do
    let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

    context :anime do
      let(:entry) { create :anime }
      before { post :reset, type: :anime }

      it { should respond_with :success }
      it { expect(user_rate.reload.score).to be_zero }
    end

    context :manga do
      let(:entry) { create :manga }
      before { post :reset, type: :manga }

      it { should respond_with :success }
      it { expect(user_rate.reload.score).to be_zero }
    end
  end

  describe :permissions do
    subject { Ability.new user }

    context :own_data do
      let(:user_rate) { build :user_rate, user: user }

      it { should be_able_to :manage, user_rate }
      it { should be_able_to :clenaup, user_rate }
      it { should be_able_to :reset, user_rate }
    end

    context :foreign_data do
      let(:user_rate) { build :user_rate, user: build_stubbed(:user) }

      it { should_not be_able_to :manage, user_rate }
    end

    context :guest do
      subject { Ability.new nil }
      let(:user_rate) { build :user_rate, user: user }

      it { should_not be_able_to :manage, user_rate }
      it { should_not be_able_to :clenaup, user_rate }
      it { should_not be_able_to :reset, user_rate }
    end
  end
end
