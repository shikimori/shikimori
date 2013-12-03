require 'spec_helper'

describe Api::V1::Profile::HistoryController do
  let(:user) { create :user }
  before { sign_in user }

  describe 'index' do
    let!(:entry_1) { create :user_history, user: user, action: 'mal_anime_import', value: '522' }
    let!(:entry_2) { create :user_history, target: create(:anime), user: user, action: 'status' }
    before { get :index, limit: 10, page: 1 }

    it { should respond_with 200 }
  end
end
