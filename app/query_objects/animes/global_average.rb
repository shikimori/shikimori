class Animes::GlobalAverage
  method_object :target_type

  TargetType = Types::Coercible::String
    .enum(Anime.name, Manga.name)

  def call
    UserRate
      .where(target_type: TargetType[target_type])
      .where.not(score: 0)
      .average(:score)
  end
end
