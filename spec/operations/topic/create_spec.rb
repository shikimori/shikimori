# frozen_string_literal: true

describe Topic::Create do
  subject! do
    described_class.call(
      faye: faye,
      params: params,
      locale: locale
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:locale) { :en }

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text'
      }
    end
    it do
      is_expected.to be_persisted
      is_expected.to have_attributes params.merge(locale: locale.to_s)
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text'
      }
    end

    it do
      is_expected.to be_new_record
      is_expected.to have_attributes params.merge(locale: locale.to_s)
      expect(subject.errors).to be_present
    end
  end
end
