class Users::ImportListWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform list_import_id
    Users::ImportList.call ListImport.find(list_import_id)
  end
end
