class RelatedEntry < SimpleDelegator
  attr_reader :relation_kind_text

  def initialize target, relation_kind_text
    super(target)
    @relation_kind_text = relation_kind_text
  end
end
