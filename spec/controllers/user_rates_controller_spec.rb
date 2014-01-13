require 'spec_helper'

describe UserRatesController do
  [:anime, :manga].each do |kind|
    describe kind do
      let(:user) { create :user }
      let(:entry) { create kind }
      let!(:user_rate) { create :user_rate, user: user, target: entry }

      let(:defaults) {{
        id: entry.to_param, type: entry.class.name
      }}

      let(:valid_hash) do
        {
          status: UserRateStatus.get(UserRateStatus::Planned),
          score: 9
        }.merge(kind == :anime ? {episodes: 0} : {volumes: 0, chapters: 0})
      end

      describe :cleanup do
        let!(:user_rate) { create :user_rate, user: user, target: entry }
        let!(:user_history) { create :user_history, user: user, target: entry }
        context :guest do
          before { post :cleanup, type: kind }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          before { post :cleanup, type: kind }

          it { should redirect_to user }
          specify { user.send("#{kind}_rates").should be_empty }
          specify { user.history.should be_empty }
        end
      end

      describe :reset do
        let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

        context :guest do
          before { post :reset, type: kind }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          before { post :reset, type: kind }

          it { should redirect_to user }
          specify { user_rate.reload.score.should be_zero }
        end
      end

      describe :create do
        context :guest do
          before { post :create, defaults }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          let(:make_request) { post :create, defaults.merge(user_rate: valid_hash) }

          context :response do
            before { make_request }
            it { should respond_with :success }
          end

          context :result do
            let(:user_rate) {}
            it { expect{make_request}.to change(UserRate, :count).by 1 }
          end
        end
      end

      describe :update do
        context :guest do
          before { put :update, defaults }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          let(:make_request) { put :update, defaults.merge(rate: valid_hash) }

          context :response do
            before { make_request }
            it { should respond_with :success }
            specify { UserRate.find(user_rate.id).score.should eq valid_hash[:score] }
          end

          context :result do
            it { expect{make_request}.to change(UserRate, :count).by 0 }
          end
        end
      end

      describe :destroy do
        context :guest do
          before { delete :destroy, defaults }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          let(:make_request) { delete :destroy, defaults }

          context :response do
            before { make_request }
            it { should respond_with :success }
          end

          context :result do
            it { expect{make_request}.to change(UserRate, :count).by -1 }
          end
        end
      end
    end
  end
end
