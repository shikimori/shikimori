class Animes::Filters::ByFranchise < Animes::Filters::FilterBase
  def call
    scope = @scope

    scope = scope.where(franchise: positives) if positives.any?

    if negatives.any?
      scope = scope.where(
        'franchise not in (?) or franchise is null',
        negatives
      )
    end

    scope
  end
end
