tdm = SVDMatrix.new(6, 4)

tdm.set_row(0, [9,8,1,2])
tdm.set_row(1, [7,9,3,1])
tdm.set_row(2, [6,8,4,1])
tdm.set_row(3, [2,1,9,8])
tdm.set_row(4, [4,3,7,6])
tdm.set_row(5, [1,2,9,9])

puts "== Term document matrix:"
p tdm

puts "\n== Decomposing matrix:"
lsa = LSA.new(tdm)
p lsa

puts "\n== Classifying new column vector: [9, 9, 0, 1]"
puts "Format is [column, similarity]"
ranks = lsa.classify_vector([9, 9, 0, 1])
p ranks

sorted_ranks = ranks.sort_by(&:last).reverse
puts "\n== Vector most similar to column #{sorted_ranks.first[0]}"
p tdm.column(sorted_ranks.first[0])

#==========================================================
#==========================================================
#==========================================================
#indexes = Anime.where { kind != 'Special' }
    #.pluck(:id)
    #.each_with_index
    #.each_with_object({}) {|(id,index),memo| memo[id] = index }

# подготовка данных для SVD матрицы
RATE_CONDITION = Entry.squeel { (status.not_eq my{UserRateStatus.get UserRateStatus::Planned}) & (score.not_eq(nil)) & (score > 0) }

entry_ids = Anime.where do
  (score >= 6) &
  (kind != 'Special') &
  (kind != 'Music') &
  (duration > 5) &
  (censored.eq(0)) &
  (status != 'Not yet aired') &
  (
    (aired_on > '1995-01-01') |
    ((score > 7.5) & (aired_on > '1990-01-01')) |
    (score > 8.0) | ((score > 7.7) & (kind.eq('Movie')))
  )
end.pluck(:id); nil

user_ids = UserRate.where(RATE_CONDITION).where(target_type: Anime.name, target_id: entry_ids).group(:user_id).having("count(*) > 100 and count(*) < 1000").pluck(:user_id).uniq; nil
entry_ids = UserRate.where(RATE_CONDITION).where(target_type: Anime.name, user_id: user_ids, target_id: entry_ids).pluck(:target_id).uniq; nil
entry_ids = UserRate.where(RATE_CONDITION).where(target_type: Anime.name, user_id: user_ids, target_id: entry_ids).group(:target_id).having('count(*) > 4').pluck(:target_id).uniq; nil

rates = entry_ids.each_with_object({}) {|v,memo| memo[v] = {} }
UserRate.where(RATE_CONDITION).where(target_type: Anime.name, user_id: user_ids, target_id: entry_ids).find_each(batch_size: 10000) do |rate|
  rates[rate.target_id][rate.user_id] = rate.score
end; nil

entry_indexes = entry_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }; nil
user_indexes = user_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }; nil

# заполнение SVD матрицы
data_matrix = SVDMatrix.new(user_ids.size, entry_ids.size); nil
empty_row = Array.new(user_ids.size, 0); nil

entry_indexes.each do |entry_id,entry_index|
  row = empty_row.clone

  rates[entry_id].each do |user_id, score|
    user_index = user_indexes[user_id]
    raise 'nil index' unless user_index
    row[user_index] = score
  end
  raise 'row overflow' if row.size > user_indexes.size

  data_matrix.set_row entry_index, row
end; nil

# вычисляем SVD
lsa = LSA.new(data_matrix); nil



# формируем вектор оценок искомого пользователя
# user_ids и entry_ids загружаем из сохранённого кеша
user_id = 1
entry_indexes = entry_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }; nil
#user_indexes = user_ids.each_with_index.each_with_object({}) {|(id,index),memo| memo[id] = index }; nil

scores_vector = Array.new(entry_ids.size, 0); nil
UserRate.where(RATE_CONDITION).where(target_type: Anime.name, user_id: user_id, target_id: entry_ids).each do |rate|
  entry_index = entry_indexes[rate.target_id]
  scores_vector[entry_index] = rate.score
end; nil

ranks = lsa.classify_vector(scores_vector); nil
similar_users = ranks.each_with_object({}) {|(index,similarity),memo| memo[user_ids[index]] = similarity }
#similar_users = ranks.select {|k,v| v > 0.9 }.each_with_object({}) {|(index,similarity),memo| memo[user_ids[index]] = similarity }
