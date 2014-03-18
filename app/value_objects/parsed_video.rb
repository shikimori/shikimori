class ParsedVideo
  include Virtus.model

  attribute :author, String
  attribute :episode, Integer
  attribute :kind, Symbol
  attribute :url, String
  attribute :source, String
  attribute :language, Symbol
end
