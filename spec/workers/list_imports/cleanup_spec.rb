describe ListImports::Cleanup do
  let!(:list_import_1) { nil }
  let!(:list_import_2) { nil }

  subject! { described_class.new.perform }

  describe 'fails expired imports' do
    let!(:list_import_1) do
      create :list_import, :pending,
        created_at: described_class::FAIL_INTERVAL.ago + 1.minute
    end
    let!(:list_import_2) do
      create :list_import, :pending,
        created_at: described_class::FAIL_INTERVAL.ago - 1.minute
    end

    it do
      expect(list_import_1.reload).to be_pending
      expect(list_import_2.reload).to be_failed
    end
  end

  describe 'deletes files of old imports' do
    let!(:list_import_1) do
      create :list_import, :failed, :shiki_json_empty,
        created_at: described_class::FILE_DELETION_INTERVAL.ago + 1.minute
    end
    let!(:list_import_2) do
      create :list_import, :failed, :shiki_json_empty,
        created_at: described_class::FILE_DELETION_INTERVAL.ago - 1.minute
    end

    it do
      expect(list_import_1.reload.list_content_type).to be_present
      expect(list_import_2.reload.list_content_type).to be_nil
    end
  end

  describe 'archive old imports' do
    let!(:list_import_1) do
      create :list_import, :failed, :shiki_json,
        created_at: described_class::ARCHIVE_INTERVAL.ago + 1.minute
    end
    let!(:list_import_2) do
      create :list_import, :failed, :shiki_json,
        created_at: described_class::ARCHIVE_INTERVAL.ago - 1.minute
    end

    it do
      expect(list_import_1.reload.is_archived).to eq false
      expect(list_import_1.output).to_not eq({})
      expect(list_import_2.reload.is_archived).to eq true
    end
  end
end
