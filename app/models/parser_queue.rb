class ParserQueue < ActiveRecord::Base
  enumerize :kind, in: %i(catalog_page)
end
