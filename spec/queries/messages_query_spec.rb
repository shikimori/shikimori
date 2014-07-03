require 'spec_helper'

describe MessagesQuery do
  before { Message.antispam = false }
  subject { query.fetch 1, 1 }
  let(:query) { MessagesQuery.new user, type }

  let(:user) { build_stubbed :user }
  let(:user_2) { build_stubbed :user }
  let!(:private) { create :message, kind: MessageType::Private, to: user, from: user_2 }
  let!(:sent) { create :message, kind: MessageType::Private, to: user_2, from: user }
  let!(:news) { create :message, kind: MessageType::Anons, to: user, from: user_2 }
  let!(:notification) { create :message, kind: MessageType::FriendRequest, to: user, from: user_2, read: true }

  describe :fetch do
    describe :inbox do
      let!(:private_2) { create :message, kind: MessageType::Private, to: user, from: user_2, dst_del: true }
      let(:type) { :inbox }

      it { should have(1).item }
      its(:first) { should eq private }
    end

    describe :sent do
      let!(:sent_2) { create :message, kind: MessageType::Private, to: user_2, from: user, src_del: true }
      let(:type) { :sent }

      it { should have(1).item }
      its(:first) { should eq sent }
    end

    describe :news do
      let(:type) { :news }
      it { should have(1).item }
      its(:first) { should eq news }
    end

    describe :notifications do
      let!(:notification_2) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, created_at: 2.hours.ago }
      let!(:notification_3) { create :message, kind: MessageType::GroupRequest, to: user, from: user_2, created_at: 3.hours.ago }
      let(:type) { :notifications }

      it { should have(2).item }
      its(:first) { should eq notification_2 }
    end
  end
end
