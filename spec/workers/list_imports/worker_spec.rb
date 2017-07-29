describe ListImports::Worker do
  let(:worker) { ListImports::Worker.new }
  let(:list_import) { create :list_import }

  before { allow(ListImports::Import).to receive :call }
  subject! { worker.perform list_import.id }

  it { expect(ListImports::Import).to have_received(:call).with list_import }
end
