# frozen_string_literal: true

require 'spec_helper'

describe Vault8 do
  let(:attrs) { { public_key: 'public', secret_key: 'private', service_url: 'http://lvh.me:3000' } }
  let(:vault8) { described_class.create!(attrs) }

  describe 'module methods' do
    describe '.create!' do
      subject { described_class.create!(attrs) }

      context 'with valid attrs' do
        it { is_expected.to be_instance_of Vault8 }
      end

      context 'with invalid attrs' do
        context 'public_key absent' do
          let(:attrs) { { secret_key: 'private', service_url: 'http://lvh.me:3000' } }

          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context 'secret_key absent' do
          let(:attrs) { { public_key: 'public', service_url: 'http://lvh.me:3000' } }

          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end

        context 'service_url absent' do
          let(:attrs) { { public_key: 'public', secret_key: 'private' } }

          it 'raise ArgumentError' do
            expect { subject }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  describe '#upload_url' do
    subject { vault8.upload_url({ path: path, current_time: current_time, until_time: until_time }) }

    let(:path) { '/upload' }
    let(:current_time) { 1_799_955_192 } # Time.new(2027, 1, 14, 21, 33, 12).to_i
    let(:until_time) { 1_799_958_792 } # Time.new(2027, 1, 14, 22, 33, 12).to_i

    it { is_expected.to eq 'http://lvh.me:3000/upload?p=public&s=b92268754db8d4b962f83bb31b22e2a435ca1e94&time=1799955192&until=1799958792' }
  end

  describe '#generate_url_for' do
    context 'for image uploading' do
      subject { vault8.generate_url_for({ path: path, current_time: current_time, until_time: until_time }) }

      let(:path) { '/upload' }
      let(:current_time) { 1_799_955_192 } # Time.new(2027, 1, 14, 21, 33, 12).to_i
      let(:until_time) { 1_799_958_792 } # Time.new(2027, 1, 14, 22, 33, 12).to_i

      it { is_expected.to eq 'http://lvh.me:3000/upload?p=public&s=b92268754db8d4b962f83bb31b22e2a435ca1e94&time=1799955192&until=1799958792' }
    end

    context 'for image getting' do
      subject { vault8.generate_url_for({ path: path }) }

      let(:path) { '/afnanfl12331/image.jpg' }

      it { is_expected.to eq 'http://lvh.me:3000/afnanfl12331/image.jpg?p=public&s=8f6dc24cb5d5125be035a9276e49887b32f72955' }
    end
  end

  describe '#encode_token' do
    let(:public_key) { 'public' }
    let(:private_key) { 'private' }
    let(:path) { '/image_uid/grayscale/name.jpeg' }
    let(:current_time) { 1_799_955_192 } # Time.new(2027, 1, 14, 21, 33, 12).to_i
    let(:until_time) { 1_799_958_792 } # Time.new(2027, 1, 14, 22, 33, 12).to_i

    context 'with all args' do
      subject { vault8.encode_token({ path: path, current_time: current_time, until_time: until_time }) }

      it { is_expected.to eq 'cadcb87ef4d88708f5de366b010b58d5b01574ad' }
    end

    context 'without until' do
      subject { vault8.encode_token({ path: path, current_time: current_time }) }

      it { is_expected.to eq '36dbd3b870e661fd72e0e18e612e6eb4b51efae2' }
    end

    context 'without current_time' do
      subject { vault8.encode_token({ path: path, until_time: until_time }) }

      it { is_expected.to eq 'ce72e88293f35d2f4b3ec7b5c357e59d8db8f173' }
    end
  end

  describe '#image_url' do
    subject { vault8.image_url(uid: uid, filters: filters, image_name: image_name) }

    let(:uid) { '731f70564f9145d79282f8267c4495ee' }
    let(:image_name) { 'john.jpg' }

    context 'with timestamps' do
      subject { vault8.image_url(uid: uid, filters: filters, image_name: image_name, current_time: current_time, until_time: until_time) }

      let(:filters) { [] }

      context 'timestams is Time object' do
        let(:current_time) { Time.new(2027, 1, 14, 21, 33, 12, '+02:00') }
        let(:until_time) { Time.new(2027, 1, 14, 22, 33, 12, '+02:00') }

        it { is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/john.jpg?p=public&s=3d87dbc06452c086ce554ccec3452af69748cd8f&time=1799955192&until=1799958792' }
      end

      context 'timestams is Fixnum object' do
        let(:current_time) { 1_799_955_192 } # Time.new(2027, 1, 14, 21, 33, 12)
        let(:until_time) { 1_799_958_792 } # Time.new(2027, 1, 14, 22, 33, 12)

        it { is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/john.jpg?p=public&s=3d87dbc06452c086ce554ccec3452af69748cd8f&time=1799955192&until=1799958792' }
      end
    end

    context 'without filters' do
      let(:filters) { [] }

      it { is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/john.jpg?p=public&s=a2d2a0be15bbecde654566e9283f6bc7b8a4890c' }
    end

    context 'with grayscale filter' do
      let(:filters) { [{ 'grayscale' => '' }] }

      it { is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/grayscale/john.jpg?p=public&s=57ea985eb5d2bc4c14d6e7b1e533c806ac7841cb' }
    end

    context 'with grayscale filter and blur' do
      let(:filters) { [{ 'grayscale' => '' }, { 'blur' => '1' }] }

      it { is_expected.to eq 'http://lvh.me:3000/731f70564f9145d79282f8267c4495ee/grayscale,blur-1/john.jpg?p=public&s=211f94a1fa78307143ac40a1ac23f442f36f55b8' }
    end
  end

  describe '#image_path' do
    subject { vault8.image_path(uid, filters, image_name) }

    let(:uid) { '731f70564f9145d79282f8267c4495ee' }
    let(:image_name) { 'john.jpg' }

    context 'without filters' do
      let(:filters) { [] }

      it { is_expected.to eq '/731f70564f9145d79282f8267c4495ee/john.jpg' }
    end

    context 'with grayscale filter' do
      let(:filters) { [{ 'grayscale' => '' }] }

      it { is_expected.to eq '/731f70564f9145d79282f8267c4495ee/grayscale/john.jpg' }
    end

    context 'with grayscale filter and blur' do
      let(:filters) { [{ 'grayscale' => '' }, { 'blur' => '1' }] }

      it { is_expected.to eq '/731f70564f9145d79282f8267c4495ee/grayscale,blur-1/john.jpg' }
    end
  end

  describe '#merged_filters' do
    subject { vault8.merged_filters(filters) }

    context 'no filters' do
      let(:filters) { [] }

      it { is_expected.to be_nil }
    end

    context 'resize_fill' do
      let(:filters) { [{ 'resize_fill' => [150, 140] }] }

      it { is_expected.to eq 'resize_fill-150-140' }
    end

    context 'grayscale' do
      let(:filters) { [{ 'grayscale' => '' }] }

      it { is_expected.to eq 'grayscale' }
    end

    context 'grayscale with nil' do
      let(:filters) { [{ 'grayscale' => nil }] }

      it { is_expected.to eq 'grayscale' }
    end

    context 'watermark' do
      let(:filters) { [{ 'watermark' => %w[logo20 center l] }] }

      it { is_expected.to eq 'watermark-logo20-center-l' }
    end

    context 'grayscale and watermark' do
      let(:filters) { [{ 'grayscale' => '' }, { 'watermark' => %w[logo20 center l] }] }

      it { is_expected.to eq 'grayscale,watermark-logo20-center-l' }
    end

    context 'resize_fill and watermark' do
      let(:filters) { [{ 'resize_fill' => [150, 140] }, { 'watermark' => %w[logo20 center l] }] }

      it { is_expected.to eq 'resize_fill-150-140,watermark-logo20-center-l' }
    end

    context 'resize_fill and grayscale' do
      let(:filters) { [{ 'resize_fill' => [150, 140] }, { 'grayscale' => '' }] }

      it { is_expected.to eq 'resize_fill-150-140,grayscale' }
    end

    context 'resize_fill and grayscale and watermark' do
      let(:filters) { [{ 'resize_fill' => [150, 140] }, { 'grayscale' => '' }, { 'watermark' => %w[logo20 center l] }] }

      it { is_expected.to eq 'resize_fill-150-140,grayscale,watermark-logo20-center-l' }
    end

    context 'filters without order' do
      let(:filters) { [{ 'resize_fill' => [150, 140], 'grayscale' => '', 'watermark' => %w[logo20 center l] }] }

      it { is_expected.to eq 'resize_fill-150-140,grayscale,watermark-logo20-center-l' }
    end

    context 'some filters with and some without order' do
      let(:filters) { [{ 'resize_fill' => [150, 140], 'watermark' => %w[logo20 center l] }, { 'grayscale' => '' }] }

      it { is_expected.to eq 'resize_fill-150-140,watermark-logo20-center-l,grayscale' }
    end
  end

  it 'has a version number' do
    expect(Vault8::VERSION).not_to be nil
  end

  describe '#upload_image' do
    subject { vault8.upload_image(image) }

    before do
      allow(response).to receive(:body).and_return(response_body)
      allow(vault8).to receive(:upload_url).and_return(upload_url)
      allow(http).to receive(:start).and_yield(http_double)
      allow(image).to receive(:respond_to?)
      allow(image).to receive(:is_a?)
      allow(image).to receive(:path)
      allow(File).to receive(:new).with(image).and_return(image)
      allow(File).to receive(:extname).with(image).and_return('.png')
      allow(UploadIO).to receive(:new).and_return(image)
      allow(http_double).to receive(:request).and_return(response)
    end

    let(:http) { Net::HTTP }
    let(:http_multipart) { Net::HTTP::Post::Multipart }
    let(:http_double) { double(:http_double) }
    let(:uid) { '0f2cb08592d04eb4a5c22da8eeca.gif' }
    let(:response) { double(:response) }
    let(:image) { double(:image) }
    let(:upload_url) { "http://lvh.me:3000#{request_uri}" }
    let(:request_uri) { '/upload?p=public&s=b92268754db8d4b962f83bb31b22e2a435ca1e94&time=1799955192&until=1799958792' }
    let(:upload_uri) { URI(upload_url) }
    let(:response_body) { "{\"response\":\"success\",\"image_uid\":\"#{uid}\"}" }
    let(:result) { { 'response' => 'success', 'image_uid' => uid } }

    context 'with param is a String' do
      before do
        allow(image).to receive(:is_a?).with(String).and_return(true)
        allow(http).to receive(:post_form).and_return(response)
      end

      it 'executes POST request to :upload_url with :url option' do
        expect(http).to receive(:post_form).with(upload_uri, url: image)
        is_expected.to eq(result)
      end
    end

    context 'with param is a File' do
      before do
        allow(image).to receive(:is_a?).with(File).and_return(true)
      end

      it 'executes POST request to :upload_url with provided file' do
        expect(http_multipart).to receive(:new).with(request_uri, file: image).and_call_original
        is_expected.to eq(result)
      end
    end

    context 'with param is a Tempfile' do
      before do
        allow(image).to receive(:is_a?).with(Tempfile).and_return(true)
      end

      it 'executes POST request to :upload_url with provided file' do
        expect(http_multipart).to receive(:new).with(request_uri, file: image).and_call_original
        is_expected.to eq(result)
      end
    end

    context 'with param responds to :tempfile' do
      before do
        allow(image).to receive(:respond_to?).with(:tempfile).and_return(true)
      end

      it 'executes POST request to :upload_url with provided file' do
        expect(http_multipart).to receive(:new).with(request_uri, file: image).and_call_original
        is_expected.to eq(result)
      end
    end

    context 'with invalid-JSON response from server' do
      before do
        allow(http).to receive(:post_form).and_return(response)
        allow(http).to receive(:start).and_return(response)
        allow(image).to receive(:is_a?).with(String).and_return(true)
      end

      let(:response_body) { 'Server error' }

      it 'returns Hash with { "response" => "error" }' do
        expect(vault8.upload_image(image)).to eq('response' => 'error')
      end
    end
  end
end
