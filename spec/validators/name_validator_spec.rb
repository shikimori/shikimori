require 'spec_helper'

class NameValidatable < Group
  include ActiveModel::Validations
  validates :name, name: true
end

describe NameValidator do
  subject { NameValidatable.new name: 'test' }

  context :valid do
    it { should allow_value('test').for :name }

    context :own_name do
      subject { NameValidatable.create! name: 'test' }
      it { should allow_value('test').for :name }
    end
  end

  context :invalid do
    context :group do
      let!(:group) { create :group, name: 'test' }
      it { should_not allow_value('test').for :name }
    end

    context :user do
      let!(:group) { create :user, nickname: 'test' }
      it { should_not allow_value('test').for :name }
    end

    context :routing do
      it { should_not allow_value('v').for :name }
      it { should_not allow_value('animes').for :name }
      it { should_not allow_value('mangas').for :name }
      it { should_not allow_value('reviews').for :name }
      it { should_not allow_value('contests').for :name }
      it { should_not allow_value('all').for :name }

      describe :message do
        let!(:group) { create :user, nickname: 'test' }
        before { subject.valid? }

        let(:message) { subject.errors.messages[:name].first }
        it { expect(message).to eq I18n.t('activerecord.errors.messages.taken') }
      end
    end
  end
end
