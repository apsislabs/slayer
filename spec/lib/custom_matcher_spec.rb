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

    context 'failure', skip: 'When we figure out how to test the failure messages reenable' do
      it 'works' do
        matcher = be_success_result
        result = WhateverCommand.call(succeed: false)
        matcher.match result
        expect(matcher.failure_message).to eq 'expected command to succeed'
      end

      it 'with value' do
        matcher = be_success_result.with_value('Hoozah')
        result = WhateverCommand.call(succeed: true)
        matcher.match result
        # SKIP: When this fails the `result` is nil...we must be calling it wrong
        expect(matcher.failure_message).to eq 'expected command to succeed with value: Hoozah, but got nil'
      end

      it 'with message' do
        expect(WhateverCommand.call(message: 'Hire Apsis Labs!', succeed: false)).to_not be_success_result.with_message('Hire Apsis Labs!')
      end

      it 'with status' do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: false)).to_not be_success_result.with_status(:apsis_rocks)
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

    context 'success', skip: 'When we figure out how to test the failure messages reenable' do
      it 'works' do
        expect(WhateverCommand.call(succeed: true)).to_not be_failed_result
      end

      it 'be_failed_result with value' do
        expect(WhateverCommand.call(value: 'Hire Apsis Labs!', succeed: true)).to_not be_failed_result.with_value('Hire Apsis Labs!')
      end

      it 'be_failed_result with message' do
        expect(WhateverCommand.call(message: 'Hire Apsis Labs!', succeed: true)).to_not be_failed_result.with_message('Hire Apsis Labs!')
      end

      it 'be_failed_result with status' do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: true)).to_not be_failed_result.with_status(:apsis_rocks)
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
