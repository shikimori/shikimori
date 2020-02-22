class Animes::Filters::ByAchievement < Animes::Filters::FilterBase
  method_object :scope, :value

  dry_type Types::Achievement::NekoId
  field :achievement

  def call
    fail_with_scope! unless anime?

    @scope.merge(
      NekoRepository.instance.find(dry_type[@value], 1)
        .animes_scope
        .except(:order)
    )
  end
end
