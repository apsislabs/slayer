require 'minitest'
require 'slayer/minitest'

RSpec.describe 'Custom Assertions' do
  subject(:mock_test) { Minitest::Test.new('mock') }

  it 'assert_success' do
    expect { mock_test.assert_success PassCommand.call(should_pass: true) }.not_to raise_error
    expect { mock_test.assert_success PassCommand.call(should_pass: false) }.to raise_error(Minitest::Assertion)
  end

  it 'refute_success' do
    expect { mock_test.refute_success PassCommand.call(should_pass: false) }.not_to raise_error
    expect { mock_test.refute_success PassCommand.call(should_pass: true) }.to raise_error(Minitest::Assertion)
  end

  it 'assert_failed' do
    expect { mock_test.assert_failed PassCommand.call(should_pass: false) }.not_to raise_error
    expect { mock_test.assert_failed PassCommand.call(should_pass: true) }.to raise_error(Minitest::Assertion)
  end

  it 'refute_failed' do
    expect { mock_test.refute_failed PassCommand.call(should_pass: true) }.not_to raise_error
    expect { mock_test.refute_failed PassCommand.call(should_pass: false) }.to raise_error(Minitest::Assertion)
  end
end
