require 'spec_helper'

describe UserRatesController do
  include_context :authenticated

  describe :edit do
    let(:user_rate) { create :user_rate, user: user }
    before { get :edit, id: user_rate.id }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
  end

  describe :destroy do
    let(:user_rate) { create :user_rate, user: user }
    before { delete :destroy, id: user_rate.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :html }
    it { expect(assigns(:user_rate)).to be_destroyed }
  end

  describe :create do
    let(:target) { create :anime }
    let(:create_params) {{ user_id: user.id, target_id: target.id, target_type: target.class.name, score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
    before { post :create, user_rate: create_params, format: :json }

    it { should respond_with :success }

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

  describe :increment do
    let(:user_rate) { create :user_rate, user: user, episodes: 1 }
    before { post :increment, id: user_rate.id, format: :json }

    it { should respond_with :success }

    describe :user_rate do
      subject { assigns :user_rate }

      its(:episodes) { should eq user_rate.episodes + 1 }
    end
  end
end
