require Rails.root.join 'config/environments/production'

Site::Application.configure do
  config.cache_store = :dalli_store, 'localhost', {
    namespace: 'shikimori_beta_v2',
    compress: true,
    value_max_bytes: 1024 * 1024 * 16
  }
  config.redis_db = 1
end
