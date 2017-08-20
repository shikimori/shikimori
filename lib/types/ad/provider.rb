module Types
  module Ad
    Provider = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:yandex_direct, :advertur, :istari)
  end
end
