describe Neko::Update do
  let(:user) { build_stubbed :user }

  before do
    allow(Neko::Request)
      .to receive(:call)
      .and_return neko_result

    allow(Neko::Apply).to receive(:call)
  end
  let(:neko_result) { { updated: 'qq', remove: 'ww', added: 'xx' } }

  subject! do
    Neko::Update.call user,
      user_rate_id:,
      action:
  end

  context 'delete' do
    let(:action) { Types::Neko::Action[:delete] }
    let(:user_rate_id) { 123 }

    it do
      expect(Neko::Request)
        .to have_received(:call)
        .with(
          id: user_rate_id,
          user_id: user.id,
          action:
        )
      expect(Neko::Apply)
        .to have_received(:call)
        .with user, neko_result
    end
  end

  context 'put' do
    let(:action) { Types::Neko::Action[:put] }

    context 'present user_rate' do
      let(:user_rate) { create :user_rate }
      let(:user_rate_id) { user_rate.id }

      it do
        expect(Neko::Request)
          .to have_received(:call)
          .with(
            id: user_rate_id,
            target_id: user_rate.target_id,
            score: user_rate.score,
            status: user_rate.status,
            episodes: user_rate.episodes,
            user_id: user.id,
            action:
          )
        expect(Neko::Apply)
          .to have_received(:call)
          .with user, neko_result
      end
    end

    context 'deleted user_rate' do
      let(:user_rate_id) { 9999988887777 }

      it do
        expect(Neko::Request)
          .to have_received(:call)
          .with(
            id: user_rate_id,
            user_id: user.id,
            action: Types::Neko::Action[:delete]
          )
        expect(Neko::Apply)
          .to have_received(:call)
          .with user, neko_result
      end
    end
  end

  context 'other actions' do
    let(:action) { Types::Neko::Action[:noop] }
    let(:user_rate_id) { nil }

    it do
      expect(Neko::Request)
        .to have_received(:call)
        .with(
          user_id: user.id,
          action:
        )
      expect(Neko::Apply)
        .to have_received(:call)
        .with user, neko_result
    end
  end
end
