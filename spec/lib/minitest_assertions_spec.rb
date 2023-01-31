require 'minitest'
require 'slayer/minitest'

RSpec.describe 'Custom Assertions' do
  subject(:mock_test) { Minitest::Test.new('mock') }

  it 'assert_ok' do
    expect { mock_test.assert_ok PassCommand.call(should_pass: true) }.not_to raise_error
    expect { mock_test.assert_ok PassCommand.call(should_pass: false) }.to raise_error(Minitest::Assertion)
  end

  it 'refute_ok' do
    expect { mock_test.refute_ok PassCommand.call(should_pass: false) }.not_to raise_error
    expect { mock_test.refute_ok PassCommand.call(should_pass: true) }.to raise_error(Minitest::Assertion)
  end

  it 'assert_err' do
    expect { mock_test.assert_err PassCommand.call(should_pass: false) }.not_to raise_error
    expect { mock_test.assert_err PassCommand.call(should_pass: true) }.to raise_error(Minitest::Assertion)
  end

  it 'refute_err' do
    expect { mock_test.refute_err PassCommand.call(should_pass: true) }.not_to raise_error
    expect { mock_test.refute_err PassCommand.call(should_pass: false) }.to raise_error(Minitest::Assertion)
  end
end
