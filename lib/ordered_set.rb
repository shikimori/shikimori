require 'set'
require 'active_support/ordered_hash'

class OrderedSet < Set
  def initialize enum = nil, &block
    @hash = ActiveSupport::OrderedHash.new
    super
  end
end
