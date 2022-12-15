RSpec.describe Slayer::Command do
  let(:fake_result) { Slayer::Result.new(nil, :default, nil) }

  context 'instantiation' do
    describe '::call' do
      it 'calls #call only once' do
        expect(NoArgCommand).to receive(:call).once.and_return(fake_result)
        NoArgCommand.call
      end
    end
  end

  context 'method wrappers' do
    describe 'instance' do
      subject { ScopedCommand.new }

      it { is_expected.to respond_to(:call) }
      it { is_expected.to respond_to(:not_call) }
      it { is_expected.not_to respond_to(:private_call) }
    end

    describe 'class' do
      subject { ScopedCommand }

      it { is_expected.to respond_to(:call) }
      it { is_expected.not_to respond_to(:not_call) }
      it { is_expected.not_to respond_to(:private_call) }
    end
  end

  # Implementation Tests
  # ---------------------------------------------
  #
  # The following unit tests test simple Implementations
  # of the Command interface for correctness. They rely
  # on the Command objects defined in the fixtures
  # directory for correctness.

  context 'result blocks' do
    it 'can run with no block' do
      result = PassCommand.call(should_pass: true)
      expect(result.success?).to be(true)
    end

    it 'yields a result block' do
      expect { |m| NoArgCommand.call(&m) }.to yield_result
    end

    it 'executes pass block on pass' do
      expect { |m| PassCommand.call(should_pass: true, &m) }.to yield_result.with_pass
      expect { |m| PassCommand.call(should_pass: false, &m) }.not_to yield_result.with_pass
    end

    it 'exectues fail block on fail' do
      expect { |m| PassCommand.call(should_pass: false, &m) }.to yield_result.with_fail
      expect { |m| PassCommand.call(should_pass: true, &m) }.not_to yield_result.with_fail
    end

    it 'executes ensure block on fail and pass' do
      expect { |m| PassCommand.call(should_pass: false, &m) }.to yield_result.with_ensure
      expect { |m| PassCommand.call(should_pass: true, &m) }.to yield_result.with_ensure
    end

    it 'executes ensure block on error' do
      rescued = false
      begin
        expect { |m| ErrorCommand.call(&m) }.to yield_result.with_ensure
      rescue ArgumentError
        rescued = true
      end
      expect(rescued).to be(true)
    end

    it 'raises error if not all defaults are handled' do
      expect { NoArgCommand.call { |r| r.pass { true } } }
        .to raise_error(Slayer::ResultNotHandledError)
    end

    it 'provides result and command to result handler' do
      NoArgCommand.call do |r|
        r.all do |value, result, command|
          expect(value).to be_a(String)
          expect(value).to eq('pass')

          expect(result).to be_a(Slayer::Result)
          expect(result.success?).to eq(true)

          expect(command).to be_a(NoArgCommand)
        end
      end
    end
  end

  context 'result' do
    context 'pass' do
      it 'returns result' do
        expect(PassCommand.call(should_pass: true)).to be_a(Slayer::Result)
      end

      it 'has the correct value' do
        result = ArgCommand.call(arg: 'arg')
        expect(result.value).to eq('arg')
        expect(result.success?).to be(true)
      end

      it 'passes with no result' do
        result = NoResultCommand.call(should_pass: true)
        expect(result.value).to be(nil)
        expect(result.success?).to be(true)
      end
    end

    context 'fail' do
      it 'returns result' do
        expect(PassCommand.call(should_pass: false)).to be_a(Slayer::Result)
      end

      it 'has the correct value' do
        result = ArgCommand.call(arg: nil)
        expect(result.value).to eq(nil)
        expect(result.success?).to be(false)
      end

      it 'fails with no result' do
        result = NoResultCommand.call(should_pass: false)
        expect(result.value).to be(nil)
        expect(result.failure?).to be(true)
      end
    end

    context 'try' do
      it 'bubbles up errors' do
        result = TryCommand.call(value: :my_value, succeed: false)
        expect(result.failure?).to be(true)
      end

      it 'has the correct value' do
        result = TryCommand.call(value: :my_value, succeed: true)
        expect(result.value).to eq(:my_value)
        expect(result.success?).to be(true)
      end
    end
  end

  context 'matchers' do
    it 'calls pass matcher' do
      success = false
      PassCommand.call(should_pass: true) do |m|
        m.pass { success = true }
        m.fail { raise 'Should Pass, not fail' }
        m.all { raise 'Should Pass, and not call `all`' }
      end
      expect(success).to be true
    end

    it 'calls fail matcher' do
      success = false
      PassCommand.call(should_pass: false) do |m|
        m.pass { raise 'Should fail, not pass' }
        m.fail { success = true }
        m.all { raise 'Should Fail, and not call `all`' }
      end
      expect(success).to be true
    end

    it 'calls all matcher' do
      success = false
      PassCommand.call(should_pass: true) do |m|
        m.all { success = true }
      end
      expect(success).to be true
    end

    it 'calls default pass matcher' do
      success = false
      PassCommand.call(should_pass: true) do |m|
        m.fail(:default) { raise "Shouldn't hit this code" }
        m.pass(:default) { success = true }
      end
      expect(success).to be true
    end

    it 'calls default fail matcher' do
      success = false
      PassCommand.call(should_pass: false) do |m|
        m.fail(:default) { success = true }
        m.pass(:default) { raise "Shouldn't hit this code" }
      end
      expect(success).to be true
    end

    it 'calls default all matcher' do
      success = false
      PassCommand.call(should_pass: false) do |m|
        m.all(:default) { success = true }
      end
      expect(success).to be true
    end

    it 'calls default matcher' do
      success = false
      NoDefaultCommand.call do |m|
        m.pass(:bar) { raise 'This should never be called' }
        m.pass(:default) { success = true }
        m.fail { raise 'This should never be called' }
      end
      expect(success).to be true
    end

    it 'calls default matcher' do
      success = false
      NoDefaultCommand.call do |m|
        m.all { success = true }
      end
      expect(success).to be true
    end
  end

  context 'invalid calls' do
    it { expect { ArgCommand.call(bar: 'arg') }.to raise_error(ArgumentError) }
    it { expect { NotImplementedCommand.call }.to raise_error(Slayer::CommandNotImplementedError) }
    it { expect { InvalidCommand.call }.to raise_error(NotImplementedError) }
  end
end
