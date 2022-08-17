class MigatePeopleBirthOn < ActiveRecord::Migration[6.1]
  def up
    Person.where.not(birth_on: nil).find_each do |person|
      puts person.id if Rails.env.development?

      person.update_column(
        :birth_on_v2,
        IncompleteDate.new(
          year: (person.birth_on.year unless person.birth_on.year == 1901),
          month: person.birth_on.month,
          day: person.birth_on.day
        )
      )
    end
  end

  def down
    Person.where.not(birth_on_v2: nil).find_each do |person|
      puts person.id if Rails.env.development?

      person.update_column(
        :birth_on,
        Date.new(person.birth_on_v2.year || 1901, person.birth_on_v2.month, person.birth_on_v2.day)
      )
    end
  end
end
