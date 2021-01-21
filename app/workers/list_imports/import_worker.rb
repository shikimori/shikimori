class ListImports::ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform list_import_id
    list_import = ListImport.find list_import_id
    return unless list_import.pending?

    ListImports::Import.call list_import
  end
end
