describe SidekiqHeartbeat do
  let(:job) { SidekiqHeartbeat.new }

  let(:environment) { ActiveSupport::StringInquirer.new 'production' }

  let(:enqueued) { SidekiqHeartbeat::MAX_ENQUEUED_TASKS + 1 }
  let(:busy) { 0 }
  let(:queues) { { 'mailers' => 1, 'visits' => 2 } }

  before do
    allow(Rails).to receive(:env).and_return environment

    allow(job).to receive(:restart_sidekiq)
    allow(job).to receive(:enqueued).and_return enqueued
    allow(job).to receive(:busy).and_return busy
    allow(job).to receive(:queues).and_return queues
    allow(job).to receive :log
  end

  before { job.perform }

  context 'heartbeat skipped',:focus do
    it { expect(job).to have_received :restart_sidekiq }
  end

  context 'heartbeat not skipped' do
    context 'not production environment' do
      let(:environment) { ActiveSupport::StringInquirer.new 'staging' }
      it { expect(job).not_to have_received :restart_sidekiq }
    end

    context 'enqueued <= 20' do
      let(:enqueued) { SidekiqHeartbeat::MAX_ENQUEUED_TASKS - 1 }
      it { expect(job).not_to have_received :restart_sidekiq }
    end

    context 'busy > 0' do
      let(:busy) { 1 }
      it { expect(job).not_to have_received :restart_sidekiq }
    end
  end
end
