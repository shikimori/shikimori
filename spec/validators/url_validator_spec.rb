class UrlValidatable
  include ActiveModel::Validations

  attr_accessor :url

  validates :url, url: true

  def initialize url
    self.url = url
  end
end

describe UrlValidator, type: :validator do
  subject { UrlValidatable.new url: '' }

  context 'valid' do
    it { is_expected.to allow_value('http://test.com').for :url }
    it { is_expected.to allow_value('http://yandex.ru/test?cvx=23').for :url }
  end

  context 'invalid' do
    it { is_expected.to_not allow_value('xn--d1acufc.xn--p1ai').for :url }
    it { is_expected.to_not allow_value('shikimori%.org').for :url }
    it { is_expected.to_not allow_value('abcd://rookee.ru').for :url }
    it { is_expected.to_not allow_value('dfsdsfsadfas').for :url }
    it { is_expected.to_not allow_value('коньки-roller.рф').for :url }

    describe 'message' do
      before { subject.valid? }
      let(:message) { subject.errors.messages[:url].first }
      it { expect(message).to eq I18n.t('activerecord.errors.messages.invalid') }
    end
  end
end
