require 'spec_helper'

describe TopicsQuery do
  let(:query) { TopicsQuery.new section, user, linked }
  let(:linked) { nil }
  let(:user) { nil }

  let(:page) { 1 }
  let(:limit) { 1 }

  subject { query.fetch page, limit }

  describe :section do
    let(:section) { create :section }
    let!(:thread_1) { create :entry, section: section }
    let!(:thread_2) { create :entry, section: build_stubbed(:section) }

    it { should eq [thread_1] }
  end

  describe :linked do
    let(:section) { create :section }
    let(:linked) { create :anime }
    let!(:thread_1) { create :entry, linked: linked, section: section }
    let!(:thread_2) { create :entry, section: section }

    it { should eq [thread_1] }
  end

  describe :pagination do
    let(:section) { create :section }
    let!(:thread_1) { create :entry, section: section, updated_at: 1.day.ago }
    let!(:thread_2) { create :entry, section: section, updated_at: 2.days.ago }

    context :first_page do
      let(:page) { 1 }
      it { should eq [thread_1, thread_2] }
    end

    context :second_page do
      let(:page) { 2 }
      it { should eq [thread_2] }
    end

    context :limit do
      let!(:thread_3) { create :entry, section: section, updated_at: 3.days.ago }
      let(:page) { 2 }
      it { should eq [thread_2, thread_3] }
    end
  end
end
