require 'spec_helper'
require 'cancan/matchers'

describe UserRatesController do
  include_context :authenticated

  describe :create do
    pending
  end

  describe :update do
    pending
  end

  describe :destroy do
    pending
  end

  describe :cleanup do
    let!(:user_rate) { create :user_rate, user: user, target: entry }
    let!(:user_history) { create :user_history, user: user, target: entry }

    context :anime do
      let(:entry) { create :anime }
      before { post :cleanup, type: :anime }

      it { should redirect_to user }
      it { expect(user.anime_rates).to be_empty }
      it { expect(user.history).to be_empty }
    end

    context :manga do
      let(:entry) { create :manga }
      before { post :cleanup, type: :manga }

      it { should redirect_to user }
      it { expect(user.manga_rates).to be_empty }
      it { expect(user.history).to be_empty }
    end
  end

  describe :reset do
    let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

    context :anime do
      let(:entry) { create :anime }
      before { post :reset, type: :anime }

      it { should redirect_to user }
      it { expect(user_rate.reload.score).to be_zero }
    end

    context :manga do
      let(:entry) { create :manga }
      before { post :reset, type: :manga }

      it { should redirect_to user }
      it { expect(user_rate.reload.score).to be_zero }
    end
  end

  describe :permissions do
    subject { Ability.new user }

    context :own_data do
      let(:user_rate) { build :user_rate, user: user }

      it { should be_able_to :manage, user_rate }
      it { should be_able_to :clenaup, user_rate }
      it { should be_able_to :reset, user_rate }
    end

    context :foreign_data do
      let(:user_rate) { build :user_rate, user: build_stubbed(:user) }

      it { should_not be_able_to :manage, user_rate }
    end

    context :guest do
      subject { Ability.new nil }
      let(:user_rate) { build :user_rate, user: user }

      it { should_not be_able_to :manage, user_rate }
      it { should_not be_able_to :clenaup, user_rate }
      it { should_not be_able_to :reset, user_rate }
    end
  end
end
