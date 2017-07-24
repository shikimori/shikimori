describe Users::ImportListWorker do
  let(:worker) { Users::ImportListWorker.new }
  let(:list_import) { create :list_import }

  before { allow(Users::ImportList).to receive :call }
  subject! { worker.perform list_import.id }

  it { expect(Users::ImportList).to have_received(:call).with list_import }
end
