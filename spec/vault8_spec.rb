require 'spec_helper'

describe Vault8 do
  describe 'module methods' do
    describe '#create!' do
      subject { described_class.create!(attrs) }
      context 'with valid attrs' do
        let(:attrs) { {public_key: 'public', secret_key: 'private', service_url: 'http://lvh.me:3000'} }
        it { is_expected.to be_instance_of Vault8::Client }
      end

      context 'with invalid attrs' do
        context 'public_key absent' do
          let(:attrs) { {secret_key: 'private', service_url: 'http://lvh.me:3000'} }
          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context 'secret_key absent' do
          let(:attrs) { {public_key: 'public', service_url: 'http://lvh.me:3000'} }
          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context 'service_url absent' do
          let(:attrs) { {public_key: 'public', secret_key: 'private'} }
          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  it 'has a version number' do
    expect(Vault8::VERSION).not_to be nil
  end
end
