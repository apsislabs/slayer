RSpec.shared_examples 'a normal method' do
  it "doesn't yield" do
    expect { |m| subject.add(2, 2, &m) }.not_to yield_control
  end

  it 'returns the expected value' do
    expect(subject.add(2, 2)).to eq(4)
  end

  it 'returns the expected type' do
    expect(subject.add(2, 2)).to be_a(Numeric)
  end
end

RSpec.describe Slayer::Service do
  context 'BoringService' do
    context 'class methods' do
      subject { BoringService }

      it_behaves_like 'a normal method'
    end

    context 'instance methods' do
      subject { BoringService.new }

      it_behaves_like 'a normal method'
    end
  end

  context 'MultiplyingService' do
    context 'class methods' do
      subject { MultiplyingService }

      it 'valid arguments return a successful response' do
        expect(subject.mul(5, 5).success?).to eq(true)
      end

      it 'invalid arguments return an failed response' do
        expect(subject.mul(0, 5).failure?).to eq(true)
      end

      it 'should #wrap_service_methods?' do
        expect(subject.wrap_service_methods?).to be true
      end
    end

    context 'instance methods' do
      subject { MultiplyingService.new }

      it 'valid arguments return a successful response' do
        expect(subject.inst_mul(5, 5).success?).to eq(true)
      end

      it 'invalid arguments return an failed response' do
        expect(subject.inst_mul(0, 5).failure?).to eq(true)
      end

      it 'should .wrap_service_methods?' do
        expect(subject.wrap_service_methods?).to be true
      end
    end
  end

  context 'RaisingService' do
    it 'returns failure result for static calls' do
      expect(RaisingService.early_halting_flunk.failure?).to eq(true)
    end

    it 'returns failure result for instance calls' do
      expect(RaisingService.new.early_halting_flunk.failure?).to eq(true)
    end
  end

  context 'TestService' do
    it 'calls block' do
      expect do |m|
        TestService.pass_5 do |r|
          r.all(&m)
        end
      end.to yield_control
    end

    it 'calls block with correct args' do
      TestService.pass_5 do |r|
        expect(r).to be_a(Slayer::ResultMatcher)
        r.all
      end
    end

    it 'calls pass block' do
      expect do |m|
        TestService.pass_5 do |r|
          r.pass(&m)
          r.fail { raise('Called Fail Matcher incorrectly') }
        end
      end.to yield_control
    end

    it 'returns pass result with value' do
      expect(TestService.pass_5.value).to eq(5)
    end

    it 'returns success? result' do
      expect(TestService.pass_5.success?).to eq(true)
    end

    it 'calls fail block' do
      expect do |m|
        TestService.flunk_10 do |r|
          r.pass { raise('Called Pass Matcher incorrectly') }
          r.fail(&m)
        end
      end.to yield_control
    end

    it 'returns fail result with value' do
      expect(TestService.flunk_10.value).to eq(10)
    end

    it 'returns failure? result' do
      expect(TestService.flunk_10.failure?).to eq(true)
    end
  end
end
