class RenameReviewToCritiqueInStyles < ActiveRecord::Migration[5.2]
  FIELDS = %i[css compiled_css]
  PREFIXES = %w[. -]

  def up
    return if Rails.env.development?

    FIELDS.each do |field|
      PREFIXES.each do |prefix|
        Style.connection.execute %Q[
          update styles
            set #{field} =
              replace(
                replace(#{field}, '#{prefix}review', '#{prefix}critique'),
                '#{prefix}pcritique', '#{prefix}preview'
              )
            where
              #{field} is not null and
              #{field} like '%#{prefix}review%'
        ]
      end
    end
  end

  def down
    return if Rails.env.development?

    FIELDS.each do |field|
      PREFIXES.each do |prefix|
        Style.connection.execute %Q[
          update styles
            set #{field} =
              replace(#{field}, '#{prefix}critique', '#{prefix}review')
            where
              #{field} is not null and
              #{field} like '%#{prefix}review%'
        ]
      end
    end
  end
end
