RSpec.describe Slayer::ResultMatcher do
  describe '#handled_defaults?' do
    subject(:matcher) do
      result = Slayer::Result.new(5, :default, 'my message')
      Slayer::ResultMatcher.new(result, NoArgCommand.new)
    end

    context 'no default pass' do
      it {
        matcher.pass(:ok, :awesome)
        matcher.all :ok
        matcher.fail
        expect(matcher.handled_defaults?).to be(false)
      }
    end

    context 'no default fail' do
      it {
        matcher.pass
        matcher.all :bad
        matcher.fail :bad, :not_found
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
          matcher.pass
          matcher.fail
          expect(matcher.handled_defaults?).to be(true)
        end
      end

      context 'with explicit defaults' do
        it 'passes with explicit defaults' do
          matcher.pass(:default)
          matcher.fail(:default)
          expect(matcher.handled_defaults?).to be(true)
        end

        it 'passes with multiple statuses' do
          matcher.pass(:default, :ok)
          matcher.fail(:default, :bad)
          expect(matcher.handled_defaults?).to be(true)
        end

        it 'passes with multiple declarations' do
          matcher.pass(:ok)
          matcher.pass
          matcher.fail(:bad)
          matcher.fail
          expect(matcher.handled_defaults?).to be(true)
        end
      end
    end
  end
end
