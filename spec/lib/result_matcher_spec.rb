RSpec.describe Slayer::ResultMatcher do
  describe '#handled_defaults?' do
    subject(:matcher) do
      result = Slayer::Result.new(5, :default, 'my message')
      Slayer::ResultMatcher.new(result, NoArgCommand.new)
    end

    context 'no default pass' do
      it {
        matcher.ok(:ok, :awesome)
        matcher.all :ok
        matcher.err
        expect(matcher.handled_defaults?).to be(false)
      }
    end

    context 'no default fail' do
      it {
        matcher.ok
        matcher.all :bad
        matcher.err :bad, :not_found
        expect(matcher.handled_defaults?).to be(false)
      }
    end

    context 'with default all' do
      it {
        matcher.all
        expect(matcher.handled_defaults?).to be(true)
      }
    end

    context 'default fail and pass' do
      context 'with implicit defaults' do
        it 'passes with implicit defaults' do
          matcher.ok
          matcher.err
          expect(matcher.handled_defaults?).to be(true)
        end
      end

      context 'with explicit defaults' do
        it 'passes with explicit defaults' do
          matcher.ok(:default)
          matcher.err(:default)
          expect(matcher.handled_defaults?).to be(true)
        end

        it 'passes with multiple statuses' do
          matcher.ok(:default, :ok)
          matcher.err(:default, :bad)
          expect(matcher.handled_defaults?).to be(true)
        end

        it 'passes with multiple declarations' do
          matcher.ok(:ok)
          matcher.ok
          matcher.err(:bad)
          matcher.err
          expect(matcher.handled_defaults?).to be(true)
        end
      end
    end
  end
end
