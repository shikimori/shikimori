shared_context :reset_repository do |klass, is_reset_after|
  before { klass.instance.reset }
  if is_reset_after
    after { klass.instance.reset }
  end
end
