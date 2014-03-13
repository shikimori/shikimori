class ParsedVideo
  include Virtus.model

  attribute :author, String
  attribute :episode, Integer
  attribute :kind, Symbol
  attribute :source, String
  attribute :url, String
  attribute :language, Symbol
end
