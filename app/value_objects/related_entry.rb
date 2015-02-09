class RelatedEntry < SimpleDelegator
  attr_reader :relation

  def initialize target, relation
    super target
    @relation = relation
  end
end
