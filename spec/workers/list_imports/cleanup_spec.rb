describe ListImports::Cleanup do
  let!(:list_import_1) do
    create :list_import, :pending,
      created_at: described_class::FAIL_INTERVAL.ago + 1.minute
  end
  let!(:list_import_2) do
    create :list_import, :pending,
      created_at: described_class::FAIL_INTERVAL.ago - 1.minute
  end

  subject! { described_class.new.perform }

  it do
    expect(list_import_1.reload).to be_pending
    expect(list_import_2.reload).to be_failed
  end
end
