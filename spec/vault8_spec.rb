require 'spec_helper'

describe Vault8 do
  let(:attrs) { {public_key: 'public', secret_key: 'private', service_url: 'http://lvh.me:3000'} }
  let(:vault8) { described_class.create!(attrs) }

  describe 'module methods' do
    describe '#create!' do
      subject { described_class.create!(attrs) }
      context 'with valid attrs' do
        let(:attrs) { {public_key: 'public', secret_key: 'private', service_url: 'http://lvh.me:3000'} }
        it { is_expected.to be_instance_of Vault8 }
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

  describe 'encode_token' do
    let(:public_key) { 'public' }
    let(:private_key) { 'private' }
    let(:path) { '/image_uid/grayscale/name.jpeg' }
    let(:current_time) { 1799955192 } # Time.new(2027, 1, 14, 21, 33, 12).to_i
    let(:until_time) { 1799958792 } #Time.new(2027, 1, 14, 22, 33, 12).to_i
    context 'with all args' do
      subject {vault8.encode_token({p: public_key, s: private_key, path: path, current_time: current_time, until_time: until_time  })}
      it { is_expected.to eq '13c2408f42fe46a64e682a7b3960d432add980f770e7da89f22808ce7295e296'}
    end

    context 'without until' do
      subject {vault8.encode_token({p: public_key, s: private_key, path: path, current_time: current_time})}
      it { is_expected.to eq '5be30e8674e936e830e4bb70b1dc09c94abcdaa8a679745a414dc3672cdcd448'}
    end

    context 'without current_time' do
      subject {vault8.encode_token({p: public_key, s: private_key, path: path, until_time: until_time})}
      it { is_expected.to eq '950c5224b94b10d0ab45c51d38365b678b98b2a1fea7baf6c602806d0f40e61a'}
    end
  end

  describe 'image_url' do
    let(:uid) {'731f70564f9145d79282f8267c4495ee'}
    let(:image_name) {'john.jpg'}
    subject {vault8.image_url(uid, filters, image_name)}

    context 'without filters' do
      let(:filters) { [] }
      it {is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/john.jpg'}
    end

    context 'with grayscale filter' do
      let(:filters) { [{'grayscale' => ''}] }
      it {is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/grayscale/john.jpg'}
    end

    context 'with grayscale filter and blur' do
      let(:filters) { [{'grayscale' => ''}, {'blur' => '1'}] }
      it {is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/grayscale,blur-1/john.jpg'}
    end
  end

  describe 'image_path' do
    let(:uid) {'731f70564f9145d79282f8267c4495ee'}
    let(:image_name) {'john.jpg'}
    subject {vault8.image_path(uid, filters, image_name)}

    context 'without filters' do
      let(:filters) { [] }
      it {is_expected.to eq '731f70564f9145d79282f8267c4495ee/john.jpg'}
    end

    context 'with grayscale filter' do
      let(:filters) { [{'grayscale' => ''}] }
      it {is_expected.to eq '731f70564f9145d79282f8267c4495ee/grayscale/john.jpg'}
    end

    context 'with grayscale filter and blur' do
      let(:filters) { [{'grayscale' => ''}, {'blur' => '1'}] }
      it {is_expected.to eq '731f70564f9145d79282f8267c4495ee/grayscale,blur-1/john.jpg'}
    end
  end

  describe 'mergerd_filters' do
    subject {vault8.merged_filters(filters)}

    context 'no filters' do
      let(:filters) {[]}
      it {is_expected.to be_nil}
    end

    context 'resize_fill' do
      let(:filters) { [{'resize_fill' => [150, 140]}] }
      it {is_expected.to eq 'resize_fill-150-140'}
    end

    context 'grayscale' do
      let(:filters) { [{'grayscale' => ''}] }
      it {is_expected.to eq 'grayscale'}
    end

    context 'grayscale with nil' do
      let(:filters) { [{'grayscale' => nil}] }
      it {is_expected.to eq 'grayscale'}
    end

    context 'watermark' do
      let(:filters) { [{'watermark' => ['logo20','center','l']}] }
      it {is_expected.to eq 'watermark-logo20-center-l'}
    end

    context 'grayscale and watermark' do
      let(:filters) { [{'grayscale' => ''}, {'watermark' => ['logo20','center','l']}] }
      it {is_expected.to eq 'grayscale,watermark-logo20-center-l'}
    end

    context 'resize_fill and watermark' do
      let(:filters) { [{'resize_fill' => [150, 140]}, {'watermark' => ['logo20','center','l']}] }
      it {is_expected.to eq 'resize_fill-150-140,watermark-logo20-center-l'}
    end

    context 'resize_fill and grayscale' do
      let(:filters) { [{'resize_fill' => [150, 140]}, {'grayscale' => ''}] }
      it {is_expected.to eq 'resize_fill-150-140,grayscale'}
    end

    context 'resize_fill and grayscale and watermark' do
      let(:filters) { [{'resize_fill' => [150, 140]}, {'grayscale' => ''}, {'watermark' => ['logo20','center','l']}] }
      it {is_expected.to eq 'resize_fill-150-140,grayscale,watermark-logo20-center-l'}
    end

    context 'filters without order' do
      let(:filters) { [{'resize_fill' => [150, 140], 'grayscale' => '', 'watermark' => ['logo20','center','l']}] }
      it {is_expected.to eq 'resize_fill-150-140,grayscale,watermark-logo20-center-l'}
    end

    context 'some filters with and some without order' do
      let(:filters) { [{'resize_fill' => [150, 140], 'watermark' => ['logo20','center','l']}, {'grayscale' => ''}] }
      it {is_expected.to eq 'resize_fill-150-140,watermark-logo20-center-l,grayscale'}
    end

  end

  it 'has a version number' do
    expect(Vault8::VERSION).not_to be nil
  end
end
