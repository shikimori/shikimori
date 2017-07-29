class ListImports::Worker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform list_import_id
    ListImports::Import.call ListImport.find(list_import_id)
  end
end
