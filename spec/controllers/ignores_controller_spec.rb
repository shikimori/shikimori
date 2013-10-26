require 'spec_helper'

describe IgnoresController do
  let (:user) { FactoryGirl.create :user }
  let (:user2) { FactoryGirl.create :user }

  let (:create_request) { post :create, id: user2.id }
  let (:destroy_request) { delete :destroy, id: user2.id }

  describe 'create' do
    it 'authorized' do
      create_request
      response.should be_unauthorized
    end

    describe 'success' do
      before (:each) { sign_in user }

      it 'success' do
        create_request
        response.should be_success

        User.find(user.id).ignores?(user2).should be_true
      end

      describe Ignore do
        it do
          expect {
            create_request
          }.to change(Ignore, :count).by(1)
        end

        it 'only once' do
          expect {
            create_request
            create_request
          }.to change(Ignore, :count).by(1)
        end
      end
    end
  end

  describe "destroy" do
    it 'unauthorized' do
      destroy_request
      response.should be_unauthorized
    end

    describe 'success' do
      before (:each) { sign_in user }

      it 'success' do
        destroy_request
        response.should be_success

        User.find(user.id).ignores?(user2).should be_false
      end

      it Ignore do
        create_request

        expect {
          destroy_request
        }.to change(Ignore, :count).by(-1)
      end
    end
  end
end

