class NameMatches::PhraseToSearchVariants < ServiceObjectBase
  pattr_initialize :phrases
  instance_cache :clean_phrases

  def call
    [
      cleaner.finalize(clean_phrases),
      cleaner.finalize(phraser.variate(clean_phrases, do_splits: false)),
      cleaner.finalize(phraser.variate(clean_phrases, do_splits: true))
    ].uniq
  end

private

  def clean_phrases
    cleaner.cleanup(Array(@phrases)).uniq
  end

  def phraser
    NameMatches::Phraser.instance
  end

  def cleaner
    NameMatches::Cleaner.instance
  end
end
