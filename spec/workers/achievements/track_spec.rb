describe Achievements::Track do
  let(:worker) { Achievements::Track.new }

  before { allow(Neko::Update).to receive :call }

  subject! { worker.perform user.id, user_rate_id, action }
  let(:user_rate_id) { 123 }
  let(:action) { Types::Neko::Action[:put].to_s }

  it do
    expect(Neko::Update)
      .to have_received(:call)
      .with user,
        user_rate_id:,
        action: Types::Neko::Action[action]
  end
end
