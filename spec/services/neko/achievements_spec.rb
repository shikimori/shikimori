describe Neko::Achievements do
  let(:user) { build_stubbed :user }
  let(:action) { Types::Neko::Action[:noop] }
  let(:user_rate) { build_stubbed :user_rate }

  before do
    allow(Neko::Request)
      .to receive(:call)
      .and_return neko_result

    allow(Neko::Apply).to receive(:call)
  end
  let(:neko_result) { { updated: 'qq', remove: 'ww', added: 'xx' } }

  subject! do
    Neko::Achievements.call(
      user: user,
      user_rate: user_rate,
      action: action
    )
  end

  it do
    expect(Neko::Request)
      .to have_received(:call)
      .with(
        id: user_rate.id,
        user_id: user.id,
        action: action
      )
    expect(Neko::Apply)
      .to have_received(:call)
      .with user, neko_result
  end
end
