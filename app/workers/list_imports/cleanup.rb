class ListImports::Cleanup
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  FAIL_INTERVAL = 7.days
  FILE_DELETION_INTERVAL = 30.days
  ARCHIVE_INTERVAL = 90.days

  def perform
    fail_expired
    delete_files
    archive
  end

private

  def fail_expired
    ListImport
      .where(state: :pending)
      .where('created_at < ?', FAIL_INTERVAL.ago)
      .update_all state: :failed
  end

  def delete_files
    ListImport
      .includes(:user)
      .where('created_at < ?', FILE_DELETION_INTERVAL.ago)
      .where.not(list_file_size: nil)
      .each do |list_import|
        list_file_name = list_import.list_file_name

        list_import.list.destroy
        list_import.update!(
          list_file_name: list_file_name,
          list_content_type: nil,
          list_file_size: nil,
          list_updated_at: nil
        )
      end
  end

  def archive
    ListImport
      .where('created_at < ?', ARCHIVE_INTERVAL.ago)
      .each do |list_import|
        list_import.update! is_archived: true, output: {}
      end
  end
end
