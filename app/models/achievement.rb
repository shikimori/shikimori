class Achievement < ApplicationRecord
  belongs_to :user

  validates :user, :neko_id, :level, :progress, presence: true

  delegate :cache_key, to: :neko

  enumerize :neko_id,
    in: Types::Achievement::NekoId.values,
    predicates: { prefix: true }

  def respond_to? *args
    super || neko.respond_to?(*args)
  end

  def respond_to_missing? *args
    super(*args) || neko.send(:respond_to_missing?, *args)
  end

  def method_missing method, *args, &block # rubocop:disable MethodMissingSuper
    neko.send method, *args, &block
  end

private

  def neko
    @neko ||= NekoRepository.instance.find neko_id, level
  end
end
