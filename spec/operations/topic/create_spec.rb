# frozen_string_literal: true

describe Topic::Create do
  subject(:topic) { Topic::Create.call faye, params, locale }

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
      expect(topic).to be_persisted
      expect(topic).to have_attributes params.merge(locale: locale.to_s)
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
      expect(topic).to be_new_record
      expect(topic).to have_attributes params.merge(locale: locale.to_s)
      expect(topic.errors).to be_present
    end
  end
end
