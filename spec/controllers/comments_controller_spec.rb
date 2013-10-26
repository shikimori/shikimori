require 'spec_helper'

describe CommentsController do
  let(:user) { build_stubbed :user }
  let(:topic) { create :entry, user: user }
  let(:comment) { create :comment, commentable: topic, user: user }
  let(:comment2) { create :comment, commentable: topic, user: user }

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
