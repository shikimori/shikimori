class Animes::Filters::ByAchievement
  method_object :scope, :value

  def call
    @scope.merge(
      NekoRepository.instance.find(@value, 1).animes_scope.except(:order)
    )
  end
end
