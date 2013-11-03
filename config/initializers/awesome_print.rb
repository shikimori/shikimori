class AwesomePrint::Formatter
  send :remove_const, :CORE
  CORE = [:array, :hash, :class, :file, :dir, :bigdecimal, :rational, :struct, :openstruct, :method, :unboundmethod]

  def awesome_openstruct(s)
    awesome_hash(s.marshal_dump)
  end
end
