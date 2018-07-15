module Types
  module Ad
    Provider = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:yandex_direct, :advertur, :istari, :special, :mytarget)

    Placement = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:menu, :content, :footer)

    Meta = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:menu_300x250, :menu_240x400, :menu_300x600, :horizontal, :footer)

    Type = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(
        :special_x300,
        :advrtr_x728,
        :advrtr_240x400,
        :yd_300x600,
        :yd_240x500,
        :yd_240x400,
        :yd_horizontal,
        :mt_300x250,
        :mt_240x400,
        :mt_300x600,
        :mt_728x90,
        :mt_footer
      )

    Platform = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:desktop, :mobile)
  end
end
