module RknConcern
  extend ActiveSupport::Concern

  included do
    def rkn_abused?
      Copyright
        .const_get(:"ABUSED_BY_RKN_#{base_class_const_part}_IDS")
        .include? id
    end

    def rkn_banned?
      Copyright
        .const_get(:"BANNED_BY_RKN_#{base_class_const_part}_IDS")
        .include? id
    end

    def rkn_banned_poster?
      Copyright
        .const_get(:"BANNED_POSTER_BY_RKN_#{base_class_const_part}_IDS")
        .include? id
    end

  private

    def base_class_const_part
      @base_class_const_part ||= self.class.base_class.name.upcase
    end
  end
end
