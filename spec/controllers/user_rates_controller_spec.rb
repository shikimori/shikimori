require 'spec_helper'

describe UserRatesController do
  [:anime, :manga].each do |kind|
    let(:user) { create :user }
    let(:entry) { create kind }
    let(:user_rate) { create :user_rate, user: user, target: entry }

    let(:defaults) do
      { id: entry.to_param, type: entry.class.name }
    end

    let (:valid_hash) do
      {
        status: UserRateStatus.get(UserRateStatus::Planned),
        score: 9
      }.merge(kind == :anime ? {episodes: 0} : {volumes: 0, chapters: 0})
    end

    describe "create" do
      it "forbidden" do
        post :create, defaults
        should respond_with 302
      end

      describe 'sign_in user' do
        before { sign_in user }

        it 'success' do
          expect {
            post :create, defaults.merge(user_rate: valid_hash)
          }.to change(UserRate, :count).by(1)

          response.should be_success
        end
      end
    end

    describe "update" do
      it "forbidden" do
        put :update, defaults
        should respond_with 302
      end

      describe 'sign_in user' do
        before { sign_in user and user_rate }

        it 'success' do
          expect {
            put :update, defaults.merge(rate: valid_hash)
          }.to change(UserRate, :count).by(0)

          UserRate.find(user_rate.id).score.should eq(valid_hash[:score])

          response.should be_success
        end
      end
    end

    describe "destroy" do
      it "forbidden" do
        delete :destroy, defaults
        should respond_with 302
      end

      describe 'sign_in user' do
        before { sign_in user and user_rate }

        describe 'creator' do
          it 'success' do
            expect {
              delete :destroy, defaults
            }.to change(UserRate, :count).by(-1)
            response.should be_success
          end
        end
      end
    end
  end
end
