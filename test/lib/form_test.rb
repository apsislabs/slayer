require 'test_helper'

class Slayer::FormTest < Minitest::Test
  def test_instantiates_with_hash
    form = PersonForm.new({name: "Luke Skywalker", age: 20})
    assert_equal "Luke Skywalker", form.name
    assert_equal 20, form.age

    assert form.name.is_a? String
    assert form.age.is_a? Integer
  end

  def test_instantiates_with_string_hash
    form = PersonForm.new({"name": "Luke Skywalker", "age": 20})
    assert_equal "Luke Skywalker", form.name
    assert_equal 20, form.age

    assert form.name.is_a? String
    assert form.age.is_a? Integer
  end

  def test_validates_good_data
    form = PersonForm.new({name: "Luke Skywalker", age: 20})

    assert form.valid?
    refute form.invalid?
  end

  def test_invalidates_bad_data
    form = PersonForm.new({name: "Luke Skywalker"})

    refute form.valid?
    assert form.invalid?
  end

  def test_revalidates_after_data_is_updated
    form = PersonForm.new({name: "Luke Skywalker"})
    refute form.valid?
    form.age = 20
    assert form.valid?
  end
end
