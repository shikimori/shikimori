shared_context :reset_repository do |klass|
  before { klass.instance.reset }
end
