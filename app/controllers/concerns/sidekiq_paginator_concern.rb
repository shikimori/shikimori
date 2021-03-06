# rubocop:disable all
# copied from https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/paginator.rb
module SidekiqPaginatorConcern
  def sidekiq_page key, pageidx = 1, page_size = 25, opts = nil
    current_page = pageidx.to_i < 1 ? 1 : pageidx.to_i
    pageidx = current_page - 1
    total_size = 0
    items = []
    starting = pageidx * page_size
    ending = starting + page_size - 1

    Sidekiq.redis do |conn|
      type = conn.type(key)
      rev = opts && opts[:reverse]

      case type
      when 'zset'
        total_size, items = conn.multi do
          conn.zcard(key)
          if rev
            conn.zrevrange(key, starting, ending, with_scores: true)
          else
            conn.zrange(key, starting, ending, with_scores: true)
          end
        end
        [current_page, total_size, items]
      when 'list'
        total_size, items = conn.multi do
          conn.llen(key)
          if rev
            conn.lrange(key, -ending - 1, -starting - 1)
          else
            conn.lrange(key, starting, ending)
          end
        end
        items.reverse! if rev
        [current_page, total_size, items]
      when 'none'
        [1, 0, []]
      else
        raise "can't page a #{type}"
      end
    end
  end
end
