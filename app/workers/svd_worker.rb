class SvdWorker
  include Sidekiq::Worker
  sidekiq_options(
    lock: :until_executed,
    dead: false,
    queue: :cpu_intensive
  )
  sidekiq_retry_in { 60 * 60 * 24 }

  def perform kind, scale, normalization
    calculate! Svd.new(kind: kind, scale: scale, normalization: normalization)
  end

private

  # расчёт SVD
  def calculate! svd
    puts "fetching user_ids, entry_ids"
    svd.user_ids, svd.entry_ids = SvdDataQuery.new(svd).fetch

    puts "preparing rates for user_ids[#{svd.user_ids.size}], entry_ids[#{svd.entry_ids.size}]"
    rates = prepare_rates svd.user_ids, svd.entry_ids, svd.normalizer, svd.klass

    puts "preparing matrix for user_ids[#{svd.user_ids.size}], entry_ids[#{svd.entry_ids.size}]"
    matrix = prepare_matrix rates, svd.user_indexes, svd.entry_indexes

    # вычисляем SVD
    puts "calculating SVD"
    svd.lsa = LSA.new matrix
    svd.save!
  end

  # оценки конкретных пользователей по конкретным аниме
  def prepare_rates user_ids, entry_ids, normalization, klass
    fetcher = Recommendations::RatesFetcher.new klass
    fetcher.by_user = false
    fetcher.with_deletion = false
    fetcher.user_ids = user_ids
    fetcher.target_ids = entry_ids
    fetcher.fetch normalization
  end

  # заполнение SVD матрицы
  # в рядах должны находиться пользователи (user_indexes), а в колонках - аниме (entry_indexes)
  def prepare_matrix rates, user_indexes, entry_indexes
    #raise "user_indexes [#{user_indexes.size}] should have more elements than entry_indexes [#{entry_indexes.size}]" if user_indexes.size < entry_indexes.size
    # матрицу при этом заполняем на оборот: в ряды аниме, а в колонки пользователей. т.к. именно таким образом у нас группируются данные
    matrix = SVDMatrix.new entry_indexes.size, user_indexes.size

    entry_indexes.each do |entry_id,entry_index|
      row = Array.new(user_indexes.size, 0)
      rates[entry_id].each do |user_id, score|
        user_index = user_indexes[user_id] || raise("nil index for user_id: #{user_id}")
        row[user_index] = score
      end
      matrix.set_row entry_index, row
    end

    puts "matrix[#{entry_indexes.size},#{user_indexes.size}]"
    matrix.instance_variable_get(:@rows).group_by {|v| v.size }.each {|k,v| puts "#{v.size} columns with #{k} elements" };

    # если пользователей больше, чем аниме, то надо перевернуть матрицу
    if user_indexes.size > entry_indexes.size
      # переворачиваем матрицу
      transpose = SVDMatrix.new user_indexes.size, entry_indexes.size
      rows = matrix.instance_variable_get(:@rows).transpose
      for i in 0..user_indexes.size-1
        transpose.set_row(i, rows[i].to_a )
      end

      puts "transposed matrix[#{user_indexes.size},#{entry_indexes.size}]"
      transpose.instance_variable_get(:@rows).group_by {|v| v.size }.each {|k,v| puts "#{v.size} columns with #{k} elements" };

      transpose
    else
      matrix
    end
  end
end
