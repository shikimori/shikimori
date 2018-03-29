describe Animes::FranchisesWorker do
  before { allow(Animes::UpdateFranchises).to receive :call }
  subject! { described_class.new.perform }
  it { expect(Animes::UpdateFranchises).to have_received(:call).with no_args }
end
