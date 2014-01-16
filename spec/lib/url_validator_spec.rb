require 'spec_helper'

class Validatable
  include ActiveModel::Validations

  attr_accessor :url
  validates :url, url: true

  def initialize url
    self.url = url
  end
end

describe UrlValidator do
  let(:url) { nil }
  subject { Validatable.new url: url }
  before { subject.valid? }
  let(:message) { subject.errors.messages[:url].first }

  context :valid do
    it { should allow_value('http://test.com').for :url }
    it { should allow_value('http://yandex.ru/test?cvx=23').for :url }
  end

  context :invalid do
    it { should_not allow_value('xn--d1acufc.xn--p1ai').for :url }
    it { should_not allow_value('shikimori%.org').for :url }
    it { should_not allow_value('abcd://rookee.ru').for :url }
    it { should_not allow_value('dfsdsfsadfas').for :url }
    it { should_not allow_value('коньки-roller.рф').for :url }

    specify { message.should eq I18n.t('activerecord.errors.messages.invalid') }
  end
end
