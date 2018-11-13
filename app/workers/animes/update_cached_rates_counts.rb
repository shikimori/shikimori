class Animes::UpdateCachedRatesCounts
  include Sidekiq::Worker
  sidekiq_options queue: :cpu_intensive

  def perform
    ApplicationRecord.connection.execute sql_query(Anime)
    ApplicationRecord.connection.execute sql_query(Manga)
  end

private

  def sql_query klass
    <<~SQL
      update #{klass.table_name}
        set cached_rates_count = rates.rates_count
        from (
          select
            #{klass.table_name}.id as target_id,
            count(user_rates.*) as rates_count
          from #{klass.table_name}
          left join user_rates on
            user_rates.target_type = '#{klass.name}'
            and user_rates.target_id = #{klass.table_name}.id
          group by #{klass.table_name}.id
        ) rates
        where #{klass.table_name}.id = rates.target_id
    SQL
  end
end
