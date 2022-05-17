require Rails.root.join 'config/environments/production'

Shikimori::Application.configure do
  config.cache_store = :mem_cache_store, 'localhost', {
    namespace: 'shiki_beta',
    compress: true,
    value_max_bytes: 1024 * 1024 * 128
  }
  config.redis_db = 1
end
