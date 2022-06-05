select scores_diversity, count(*)
  from
    (
      select user_id, count(distinct score) as scores_diversity
        from
          user_rates
        where
          score != 0 and target_type = 'Anime'
        group by
          user_id
    ) a
  group by scores_diversity
  order by scores_diversity


select count(distinct user_id)
  from
    user_rates
  where
    score != 0 and target_type = 'Anime'


select avg(score)
  from user_rates
  where
    score != 0 and target_type = 'Anime'

select avg(score)
  from user_rates
  where
    score != 0 and target_type = 'Anime'
    and user_id not in (
      select user_id
        from
          (
            select user_id, count(distinct score) as scores_diversity
              from
                user_rates
              where
                score != 0 and target_type = 'Anime'
              group by
                user_id
          ) a
        where
          scores_diversity <= 3
    )


select user_id
  from
    (
      select user_id, count(distinct score) as scores_diversity
        from
          user_rates
        where
          score != 0 and target_type = 'Anime'
        group by
          user_id
    ) a
  where
    scores_diversity = 1
  limit 10

