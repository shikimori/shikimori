class Api::V1::PeopleController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/people/:id", "Show a person"
  def show
    person = Person.find params[:id]
    @resource = person.seyu? ? SeyuDecorator.new(person) : PersonDecorator.new(person)
  end
end
