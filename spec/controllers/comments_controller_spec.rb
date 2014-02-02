require 'spec_helper'

describe CommentsController do
  let(:user) { build_stubbed :user }
  let(:topic) { create :entry, user: user }
  let(:comment) { create :comment, commentable: topic, user: user }
  let(:comment2) { create :comment, commentable: topic, user: user }

  describe :create do
    let(:user) { create :user }
    before { sign_in user }

    context :success do
      before { post :create, comment: { commentable_id: topic.id, commentable_type: topic.class.name, body: 'test', offtopic: false, review: false } }

      it { should respond_with :success }
      it { should respond_with_content_type :json }
      specify { assigns(:comment).should be_persisted }
    end

    context :failure do
      before { post :create, comment: { body: 'test', offtopic: false, review: false } }

      it { should respond_with 422 }
      it { should respond_with_content_type :json }
    end
  end

  describe :update do
    let(:user) { create :user }
    before { sign_in user }

    context :success do
      before { patch :update, id: comment.id, comment: { body: 'testzxc' } }

      it { should respond_with :success }
      it { should respond_with_content_type :json }
      specify { assigns(:comment).body.should eq 'testzxc' }
    end
  end

  describe :fetch do
    it 'works' do
      get :fetch, id: comment.id, topic_id: topic.id, skip: 1
      response.should be_success
    end

    it 'not_found for wrong comment' do
      lambda {
        get :fetch, id: comment.id+1, topic_id: topic.id, skip: 1
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'not_found for wrong topic' do
      lambda {
        get :fetch, id: comment.id, topic_id: topic.id+1, skip: 1
      }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'forbidden for mismatched comment and topic' do
      get :fetch, id: create(:comment).id, topic_id: topic.id, skip: 1
      response.should be_forbidden

      get :fetch, id: comment.id, topic_id: create(:entry).id, skip: 1
      response.should be_forbidden
    end
  end

  describe :chosen do
    let(:user) { create :user }

    describe 'one' do
      before { get :chosen, ids: "#{comment.id}" }
      it { should respond_with :success }
    end

    describe 'multiple' do
      before { get :chosen, ids: "#{comment.id},#{comment2.id}" }
      it { should respond_with :success }
    end

    describe 'unexisted' do
      before { get :chosen, ids: "#{comment2.id+1}" }
      it { should respond_with :success }
    end
  end

  describe :postload do
    before { get :postloader, commentable_type: topic.class.name, commentable_id: topic.id }
    it { should respond_with :success }
  end
end
