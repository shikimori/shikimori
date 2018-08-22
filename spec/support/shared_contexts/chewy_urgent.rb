# frozen_string_literal: true

shared_context :chewy_urgent do
  # around { |example| Chewy.strategy(:urgent) { example.run } }
  before { Chewy.strategy.push :urgent }
  after { Chewy.strategy.pop }
end
