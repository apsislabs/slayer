class PersonForm < Slayer::Form
  attribute :name, String
  attribute :age, Integer

  validations do
    required(:name) { str? }
    required(:age) { int? }
  end
end
