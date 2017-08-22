module Types
  module Ad
    Provider = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:yandex_direct, :advertur, :istari)

    Placement = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:menu, :content)
  end
end
