class UnsupportedListType < Exception
  def initialize list_type
    super "List type #{list_type} is not supported yet"
  end
end
