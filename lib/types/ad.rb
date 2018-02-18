module Types
  module Ad
    Provider = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:yandex_direct, :advertur, :istari, :vgtrk)

    Placement = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:menu, :content)
  end
end
