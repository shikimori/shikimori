require Rails.root.join 'config/environments/production'

Site::Application.configure do
  config.cache_store = :dalli_store, 'localhost', {
    namespace: 'shikimori_beta',
    compress: true,
    value_max_bytes: 1024 * 1024 * 128
  }
  config.redis_db = 1
end
