require 'spec_helper'

describe UserRatesOldController do
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
          score: 9,
          notice: 'test zxc'
        }.merge(kind == :anime ? {episodes: 0} : {volumes: 0, chapters: 0})
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
          before { patch :update, defaults }
          it { should respond_with 302 }
        end

        context :authenticated do
          before { sign_in user }
          let(:current_hash) { valid_hash.merge kind == :anime ? {episodes: 1} : {volumes: 2, chapters: 3} }
          let(:make_request) { patch :update, defaults.merge(rate: current_hash) }

          context :response do
            before { make_request }
            it { should respond_with :success }

            if kind == :anime
              it { user_rate.reload.episodes.should eq 1 }
            else
              it { user_rate.reload.volumes.should eq 2 }
              it { user_rate.reload.chapters.should eq 3 }
            end
            it { user_rate.reload.score.should eq valid_hash[:score] }
            it { user_rate.reload.notice.should eq valid_hash[:notice] }
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
