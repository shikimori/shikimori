# frozen_string_literal: true

describe Topic::Create do
  subject(:topic) do
    described_class.call(
      faye: faye,
      params: params,
      locale: locale
    )
  end

  let(:faye) { FayeService.new user, nil }
  let(:locale) { :en }
  let(:is_broadcast_required) { false }

  before do
    allow(Notifications::BroadcastTopic).to receive :perform_in
    allow_any_instance_of(Topic::BroadcastPolicy)
      .to receive(:required?)
      .and_return is_broadcast_required
  end

  context 'valid params' do
    let(:params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text',
        broadcast: broadcast,
        type: type,
        generated: generated,
        linked_id: linked_id,
        linked_type: linked_type
      }
    end
    let(:broadcast) { nil }
    let(:type) { Topic.name }
    let(:generated) { nil }
    let(:linked_id) { nil }
    let(:linked_type) { nil }

    it do
      is_expected.to be_persisted
      is_expected.to have_attributes params.merge(locale: locale.to_s, is_censored: false)
      expect(Notifications::BroadcastTopic).to_not have_received :perform_in
    end

    describe 'broadcast required' do
      let(:is_broadcast_required) { true }

      it do
        is_expected.to be_persisted
        expect(Notifications::BroadcastTopic)
          .to have_received(:perform_in)
          .with 10.seconds, topic.id
      end
    end

    describe 'NewsTopic & premoderation' do
      let(:type) { Topics::NewsTopic.name }

      context 'trusted_newsmaker' do
        let(:user) { create :user, :trusted_newsmaker }

        it do
          is_expected.to be_persisted
          is_expected.to have_attributes(
            **params.merge(locale: locale.to_s),
            forum_id: Forum::NEWS_ID
          )
        end
      end

      context 'not trusted_newsmaker' do
        it do
          is_expected.to be_persisted
          is_expected.to have_attributes(
            **params.merge(locale: locale.to_s),
            forum_id: Forum::PREMODERATION_ID
          )
        end
      end
    end

    describe 'is_censored from linked' do
      let(:anime) { create :anime, is_censored: is_censored }
      let(:is_censored) { [true, false].sample }
      let(:linked_id) { anime.id }
      let(:linked_type) { anime.class.name }
      it { expect(subject.is_censored).to eq is_censored }
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
      expect(topic.errors).to be_present
      expect(Notifications::BroadcastTopic).to_not have_received :perform_in
    end
  end
end
