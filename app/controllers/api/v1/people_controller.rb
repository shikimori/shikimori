class Api::V1::PeopleController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/people/:id", "Show a person"
  def show
    person = Person.find params[:id]

    if person.seyu?
      respond_with SeyuDecorator.new(person), serializer: SeyuProfileSerializer
    else
      respond_with PersonDecorator.new(person), serializer: PersonProfileSerializer
    end
  end
end
