class AddRolesToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :producer, :boolean, :default => false

    ids = PersonRole.where(
        { :role.like => 'Chief Producer' } |
        { :role.like => 'Chief Producer,%' } |
        { :role.like => '%, Chief Producer' } |
        { :role.like => '%, Chief Producer,%' } |
        { :role.like => 'Director' } |
        { :role.like => 'Director,%' } |
        { :role.like => '%, Director' } |
        { :role.like => '%, Director,%' }).
      select('distinct(person_id)').
      all.
      map(&:person_id)

    Person.where(:id => ids).
      update_all(:producer => true)

    add_column :people, :mangaka, :boolean, :default => false
    Person.where(:id => PersonRole.where(:role => ['Original Creator', 'Story & Art', 'Story', 'Art']).select('distinct(person_id)').all.map(&:person_id)).update_all(:mangaka => true)

    add_column :people, :seyu, :boolean, :default => false
    Person.where(:id => PersonRole.where(:role => 'Japanese').select('distinct(person_id)').all.map(&:person_id)).update_all(:seyu => true)
  end

  def self.down
    remove_column :people, :producer
    remove_column :people, :mangaka
    remove_column :people, :seyu
  end
end
