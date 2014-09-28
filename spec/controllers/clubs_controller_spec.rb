require 'spec_helper'

describe ClubsController do
  let!(:club) { create :group, :with_thread }
  let(:user) { create :user }
  let!(:group_role) { create :group_role, group: club, user: user, role: 'admin' }

  describe :index do
    describe :no_pagination do
      before { get :index }
      it { should respond_with :success }
      it { expect(assigns :collection).to eq [club] }
    end

    describe :pagination do
      before { get :index, page: 1 }
      it { should respond_with :success }
    end
  end

  describe :show do
  end
end
