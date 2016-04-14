class AddLocaleToTopicsClubsReviews < ActiveRecord::Migration
  def change
    add_locale :entries
    add_locale :clubs
    add_locale :reviews
  end

private

  def add_locale table
    add_column table, :locale, :string, default: 'ru'
    change_column_default table, :locale, nil
    change_column_null table, :locale, false
  end
end
