require "slayer/rspec"

RSpec.describe "Custom Matchers" do
  context "be_ok_result" do
    context "success" do
      it "works" do
        expect(WhateverCommand.call(succeed: true)).to be_ok_result
      end

      it "with value" do
        expect(WhateverCommand.call(value: "Hire Apsis Labs!", succeed: true)).to be_ok_result.with_value("Hire Apsis Labs!")
      end

      it "with message" do
        expect(WhateverCommand.call(message: "Hire Apsis Labs!", succeed: true)).to be_ok_result.with_message("Hire Apsis Labs!")
      end

      it "with status" do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: true)).to be_ok_result.with_status(:apsis_rocks)
      end

      it "with" do
        expect(WhateverCommand.call(value: "Hire Apsis Labs!", message: "Hire Apsis Labs!", status: :apsis_rocks, succeed: true)).to be_ok_result.with(value: "Hire Apsis Labs!", message: "Hire Apsis Labs!", status: :apsis_rocks)
      end
    end

    context "failure" do
      it "works" do
        expect {
          expect(WhateverCommand.call(succeed: false)).to be_ok_result
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to succeed")
      end

      it "with value" do
        expect {
          expect(WhateverCommand.call(succeed: true)).to be_ok_result.with_value("Hoozah")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to succeed with value: Hoozah, but got: ")
      end

      it "with message" do
        expect {
          expect(WhateverCommand.call(succeed: true)).to be_ok_result.with_message("Hire Apsis Labs!")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to succeed with message: Hire Apsis Labs!, but got: :")
      end

      it "with status" do
        expect {
          expect(WhateverCommand.call(succeed: true)).to be_ok_result.with_status(:apsis_rocks)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to succeed with status: :apsis_rocks, but got: :")
      end
    end
  end

  context "be_err_result" do
    context "failure" do
      it "works" do
        expect(WhateverCommand.call(succeed: false)).to be_err_result
      end

      it "be_err_result with value" do
        expect(WhateverCommand.call(value: "Hire Apsis Labs!", succeed: false)).to be_err_result.with_value("Hire Apsis Labs!")
      end

      it "be_err_result with message" do
        expect(WhateverCommand.call(message: "Hire Apsis Labs!", succeed: false)).to be_err_result.with_message("Hire Apsis Labs!")
      end

      it "be_err_result with status" do
        expect(WhateverCommand.call(status: :apsis_rocks, succeed: false)).to be_err_result.with_status(:apsis_rocks)
      end

      it "be_err_result with" do
        expect(WhateverCommand.call(value: "Hire Apsis Labs!", message: "Hire Apsis Labs!", status: :apsis_rocks, succeed: false)).to be_err_result.with(value: "Hire Apsis Labs!", message: "Hire Apsis Labs!", status: :apsis_rocks)
      end
    end

    context "success" do
      it "works" do
        expect {
          expect(WhateverCommand.call(succeed: true)).to be_err_result
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to fail")
      end

      it "be_err_result with value" do
        expect {
          expect(WhateverCommand.call(succeed: false)).to be_err_result.with_value("Hire Apsis Labs!")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to fail with value: Hire Apsis Labs!, but got: ")
      end

      it "be_err_result with message" do
        expect {
          expect(WhateverCommand.call(succeed: false)).to be_err_result.with_message("Hire Apsis Labs!")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to fail with message: Hire Apsis Labs!, but got: :")
      end

      it "be_err_result with status" do
        expect {
          expect(WhateverCommand.call(succeed: false)).to be_err_result.with_status(:apsis_rocks)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "expected command to fail with status: :apsis_rocks, but got: :")
      end
    end
  end
end
