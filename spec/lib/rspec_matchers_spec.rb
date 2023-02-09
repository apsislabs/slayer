require 'rspec'
require 'slayer/rspec'

RSpec.describe 'Custom Rspec Matchers' do
  # These tests are weird, but basically if they don't throw errors
  # and pass, then our custom matchers are working
  it 'be_ok_result' do
    expect(WhateverCommand.call(succeed: true, status: :foo, message: 'foo',
                                value: 'foo')).to be_ok_result.with_status(:foo).with_value('foo').with_message('foo')
    expect(WhateverCommand.call(succeed: true, status: :foo, message: 'foo',
                                value: 'foo')).to be_ok_result.with({ status: :foo,
                                                                      value: 'foo', message: 'foo' })
  end

  it 'be_err_result' do
    expect(WhateverCommand.call(succeed: false, status: :foo, message: 'foo',
                                value: 'foo')).to be_err_result.with_status(:foo).with_value('foo').with_message('foo')
    expect(WhateverCommand.call(succeed: false, status: :foo, message: 'foo',
                                value: 'foo')).to be_err_result.with({ status: :foo,
                                                                       value: 'foo', message: 'foo' })
  end

  describe 'stubs' do
    context 'passing fake result' do
      # We tell it to fail, but we stubbed a passing result, so it should
      # give us back an ok result

      let(:fake_res) { fake_result(ok: true) }

      it 'works with result as argument' do
        expect { stub_command_response(PassCommand, fake_res) }.not_to raise_error
        expect(PassCommand.call(should_pass: false)).to be_ok_result
      end

      it 'works with result as block' do
        expect { stub_command_response(PassCommand) { fake_res } }.not_to raise_error
        expect(PassCommand.call(should_pass: false)).to be_ok_result
      end
    end

    context 'failing fake result' do
      # We tell our command to pass, but we stubbed a failing result, so it should
      # give us back a failing result

      let(:fake_res) { fake_result(ok: false) }

      it 'works with result as argument' do
        expect { stub_command_response(PassCommand, fake_res) }.not_to raise_error
        expect(PassCommand.call(should_pass: true)).to be_err_result
      end

      it 'works with result as block' do
        expect { stub_command_response(PassCommand) { fake_res } }.not_to raise_error
        expect(PassCommand.call(should_pass: true)).to be_err_result
      end
    end
  end
end
