module Types
  module Ad
    Provider = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:yandex_direct, :advertur, :special, :mytarget)

    Placement = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:menu, :content, :footer)

    Meta = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(
        :menu_300x250,
        :menu_240x400,
        :menu_300x600,
        :horizontal_x250,
        :horizontal_x90,
        :footer,
        :special_x1170
      )

    Type = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(
        :special_x300,
        :special_x1170,
        :advrtr_x728,
        :advrtr_240x400,
        :advrtr_300x250,
        :yd_300x600,
        :yd_240x600,
        :yd_240x500,
        :yd_240x400,
        :yd_970x250,
        :yd_970x90,
        :mt_300x250,
        :mt_240x400,
        :mt_300x600,
        :mt_970x250,
        :mt_728x90,
        :mt_footer_300x250
      )

    Platform = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:desktop, :mobile)
  end
end
