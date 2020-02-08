describe ListImports::ImportWorker do
  let(:worker) { described_class.new }
  let(:list_import) { create :list_import, state }

  before { allow(ListImports::Import).to receive :call }
  subject! { worker.perform list_import.id }

  context 'pending' do
    let(:state) { :pending }
    it { expect(ListImports::Import).to have_received(:call).with list_import }
  end

  context 'failed' do
    let(:state) { :failed }
    it { expect(ListImports::Import).to_not have_received :call }
  end

  context 'finished' do
    let(:state) { :finished }
    it { expect(ListImports::Import).to_not have_received :call }
  end
end
