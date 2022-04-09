class AmazingPrint::Formatter
  send :remove_const, :CORE_FORMATTERS
  CORE_FORMATTERS = [:array, :bigdecimal, :class, :dir, :file, :hash, :method, :rational, :set, :struct, :unboundmethod, :openstruct]

  def amazing_openstruct(s)
    amazing_hash(s.marshal_dump)
  end
end
