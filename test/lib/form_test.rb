require 'test_helper'

class Slayer::FormTest < Minitest::Test
  def test_instantiates_with_hash
    form = PersonForm.new({ name: 'Luke Skywalker', age: 20 })
    assert_equal 'Luke Skywalker', form.name
    assert_equal 20, form.age

    assert form.name.is_a? String
    assert form.age.is_a? Integer
  end

  def test_instantiates_with_string_hash
    form = PersonForm.new({ 'name' => 'Luke Skywalker', 'age' => 20 })
    assert_equal 'Luke Skywalker', form.name
    assert_equal 20, form.age

    assert form.name.is_a? String
    assert form.age.is_a? Integer
  end

  def test_instantiates_with_mixed_hash
    form = PersonForm.new({ name: 'Luke Skywalker', 'age' => 20 })
    assert_equal 'Luke Skywalker', form.name
    assert_equal 20, form.age

    assert form.name.is_a? String
    assert form.age.is_a? Integer
  end

  def test_validate_raises_exception_if_validating_without_rails
    assert_raises NotImplementedError do
      PersonForm.new.validate!
    end
  end
end
