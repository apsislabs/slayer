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

    #   def test_executes_ensure_block_on_error
    #     assert_executes do
    #       assert_raises ArgumentError do
    #         ArgCommand.call(arg: 'arg') do |r|
    #           r.pass   { raise ArgumentError, 'I died' }
    #           r.fail   { flunk }
    #           r.ensure { executes }
    #         end
    #       end
    #     end
    #   end
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
      expect { NoArgCommand.call { |r| r.pass {} } }
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

  context 'invalid calls' do
    it { expect { ArgCommand.call(bar: 'arg') }.to raise_error(ArgumentError) }
    it { expect { NotImplementedCommand.call }.to raise_error(Slayer::CommandNotImplementedError) }
    it { expect { InvalidCommand.call }.to raise_error(NotImplementedError) }
  end
end
