RSpec.describe String do
  context 'transform string casing' do
    describe '::underscore' do
      context 'camelcase' do
        subject { 'CamelcaseString'.underscore }
        it { is_expected.to eq('camelcase_string') }
      end

      context 'snake case' do
        subject { 'snake_case'.underscore }
        it { is_expected.to eq('snake_case') }
      end

      context 'screaming snake case' do
        subject { 'SCREAMING_SNAKE_CASE'.underscore }
        it { is_expected.to eq('screaming_snake_case') }
      end

      context 'nested class names' do
        subject { 'Nested::ClassName'.underscore }
        it { is_expected.to eq('nested/class_name') }
      end

      context 'all caps' do
        subject { 'ALLCAPS'.underscore }
        it { is_expected.to eq('allcaps') }
      end
    end
  end
end
