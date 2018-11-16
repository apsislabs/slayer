require 'slayer/rspec'

RSpec.describe 'Custom Matchers' do
  it 'be_success_result' do
    expect(PassCommand.call(should_pass: true)).to be_success_result
  end

  it 'be_failed_result' do
    expect(PassCommand.call(should_pass: false)).to be_failed_result
  end
end
