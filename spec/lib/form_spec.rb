RSpec.shared_examples 'a form' do
  it 'sets values correctly' do
    expect(form.name).to eq('Luke Skywalker')
    expect(form.age).to eq(20)
  end

  it 'sets values with correct type' do
    expect(form.name).to be_a(String)
    expect(form.age).to be_a(Integer)
  end
end

RSpec.describe Slayer::Form do
  describe '::new' do
    context 'with symbol hash' do
      it_behaves_like 'a form' do
        let(:form) { PersonForm.new({ name: 'Luke Skywalker', age: 20 }) }
      end
    end

    context 'with string hash' do
      it_behaves_like 'a form' do
        let(:form) { PersonForm.new({ 'name' => 'Luke Skywalker', 'age' => 20 }) }
      end
    end

    context 'with mixed hash' do
      it_behaves_like 'a form' do
        let(:form) { PersonForm.new({ name: 'Luke Skywalker', 'age' => 20 }) }
      end
    end
  end
end
