require 'test_helper'

class Slayer::StringExtTest < Minitest::Test
  def test_underscores_camelcase
    assert_equal "camelcase_string", "CamelcaseString".underscore
  end

  def test_underscores_screaming_snake_case
    assert_equal "screaming_snake_case", "SCREAMING_SNAKE_CASE".underscore
  end

  def test_underscores_class_name
    assert_equal "nested/class_name", "Nested::ClassName".underscore
  end

  def test_underscores_underscore
    assert_equal "already_underscored", "already_underscored".underscore
  end

  def test_underscores_all_caps
    assert_equal "allcaps", "ALLCAPS".underscore
  end
end
