# Shared Examples:
RSpec.shared_examples 'a hooked method' do |method_name, times|
  it "#{times == 0 ? 'does not wrap' : 'wraps'} the method" do
    expect do |m|
      subject.send(method_name, &m)
    end.to yield_control.exactly(times).times
  end
end

RSpec.shared_examples 'a hooked class' do |klass, method_name, times|
  context 'instance method' do
    subject { klass.new }

    it_behaves_like 'a hooked method', method_name, times
  end

  context 'class method' do
    subject { klass }

    it_behaves_like 'a hooked method', method_name, times
  end
end

# Specs:
RSpec.describe Slayer::Hook do
  describe '.hook' do
    it_behaves_like 'a hooked class', SimpleHook, :simple, 1
  end

  describe '.skip_hook' do
    it_behaves_like 'a hooked class', SkipHooks, :a, 0
    it_behaves_like 'a hooked class', SkipHooks, :c, 1
  end

  describe '.singleton_skip_hook' do
    context 'instance method' do
      subject { SkipHooks.new }

      it_behaves_like 'a hooked method', :b, 0
    end

    context 'class method' do
      subject { SkipHooks }

      it_behaves_like 'a hooked method', :b, 1
    end
  end

  describe '.only_hook' do
    it_behaves_like 'a hooked class', OnlyHook, :a, 1
    it_behaves_like 'a hooked class', OnlyHook, :b, 1
    it_behaves_like 'a hooked class', OnlyHook, :c, 0
  end

  context 'no hooks' do
    it_behaves_like 'a hooked class', NoHooks, :a, 0
    it_behaves_like 'a hooked class', NoHooks, :b, 0
  end
end
