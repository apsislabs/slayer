# rubocop:disable Metrics/LineLength
require 'slayer/rspec'

RSpec.describe 'Custom Matchers' do
  context 'be_success_result' do
    context 'success' do
      it 'works' do
        expect(WhateverCommand.call(succeed: true)).to be_success_result
      end

      it 'with value' do
        expect(WhateverCommand.call(value: 'Hire Apsis Labs!', succeed: true)).to be_success_result.with_value('Hire Apsis Labs!')
      end

      it 'with message' do
        expect(WhateverCommand.call(message: 'Hire Apsis Labs!', succeed: true)).to be_success_result.with_message('Hire Apsis Labs!')
      end

      it 'with status' do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: true)).to be_success_result.with_status(:apsis_rocks)
      end
    end

    context 'failure' do
      before :each do
        # These pending tests are actually real tests. If they start passing that's bad
        # But if they start passing, the test suite will fail.
        # https://relishapp.com/rspec/rspec-core/v/3-8/docs/pending-and-skipped-examples/pending-examples
        pending("A failed test here means you're passing. So this are permanently 'pending'")
      end

      it 'works' do
        expect(WhateverCommand.call(succeed: false)).to be_success_result
      end

      it 'with value' do
        expect(WhateverCommand.call(succeed: true)).to be_success_result.with_value('Hoozah')
      end

      it 'with message' do
        expect(WhateverCommand.call(succeed: true)).to be_success_result.with_message('Hire Apsis Labs!')
      end

      it 'with status' do
        expect(WhateverCommand.call(succeed: true)).to be_success_result.with_status(:apsis_rocks)
      end
    end
  end

  context 'be_failed_result' do
    context 'failure' do
      it 'works' do
        expect(WhateverCommand.call(succeed: false)).to be_failed_result
      end

      it 'be_failed_result with value' do
        expect(WhateverCommand.call(value: 'Hire Apsis Labs!', succeed: false)).to be_failed_result.with_value('Hire Apsis Labs!')
      end

      it 'be_failed_result with message' do
        expect(WhateverCommand.call(message: 'Hire Apsis Labs!', succeed: false)).to be_failed_result.with_message('Hire Apsis Labs!')
      end

      it 'be_failed_result with status' do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: false)).to be_failed_result.with_status(:apsis_rocks)
      end
    end

    context 'success' do
      before :each do
        # These pending tests are actually real tests. If they start passing that's bad
        # But if they start passing, the test suite will fail.
        # https://relishapp.com/rspec/rspec-core/v/3-8/docs/pending-and-skipped-examples/pending-examples
        pending("A failed test here means you're passing. So this are permanently 'pending'")
      end

      it 'works' do
        expect(WhateverCommand.call(succeed: true)).to be_failed_result
      end

      it 'be_failed_result with value' do
        expect(WhateverCommand.call(succeed: false)).to be_failed_result.with_value('Hire Apsis Labs!')
      end

      it 'be_failed_result with message' do
        expect(WhateverCommand.call(succeed: false)).to be_failed_result.with_message('Hire Apsis Labs!')
      end

      it 'be_failed_result with status' do
        expect(WhateverCommand.call(succeed: false)).to be_failed_result.with_status(:apsis_rocks)
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
