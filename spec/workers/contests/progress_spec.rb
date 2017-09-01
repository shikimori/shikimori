describe Contests::Progress do
  let!(:contest_created) { create :contest, :created }
  let!(:contest_proposing) { create :contest, :proposing }
  let!(:contest_started) { create :contest, :started }
  let!(:contest_finished) { create :contest, :finished }

  before { allow(Contest::Progress).to receive :call }

  subject! { Contests::Progress.new.perform }

  it do
    expect(Contest::Progress).to have_received(:call).once
    expect(Contest::Progress).to have_received(:call).with contest_started
  end
end
