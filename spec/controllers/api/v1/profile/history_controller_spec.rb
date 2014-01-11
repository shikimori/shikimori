require 'spec_helper'

describe Api::V1::Profile::HistoryController do
  let(:user) { create :user }
  before { sign_in user }
  let!(:entry_1) { create :user_history, user: user, action: 'mal_anime_import', value: '522' }
  let!(:entry_2) { create :user_history, target: create(:anime), user: user, action: 'status' }

  describe 'index' do
    before { get :index, limit: 10, page: 1, format: :json }
    it { should respond_with 200 }
  end

  describe 'show' do
    before { get :show, id: user.to_param, climit: 10, page: 1, format: :json }
    it { should respond_with 200 }
  end
end
