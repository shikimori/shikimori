require 'ostruct'

class DeepStruct < OpenStruct # rubocop:disable Style/OpenStructUse
  def initialize hash = nil
    super

    @table = {}
    @hash_table = {}

    hash&.each do |k, v|
      @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
      @hash_table[k.to_sym] = v

      new_ostruct_member!(k)
    end
  end

  def to_h
    @hash_table
  end
end
