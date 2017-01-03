require 'spec_helper'

describe Vault8::Client do
  let(:client) { described_class.new('public', 'private', 'http://lvh.me:4000')}

  describe 'image_url' do
    let(:uid) {'731f70564f9145d79282f8267c4495ee'}
    let(:image_name) {'john.jpg'}
    subject {client.image_url(uid, filters, image_name)}

    context 'without filters' do
      let(:filters) { [] }
      it {is_expected.to eq 'http://lvh.me:4000/731f70564f9145d79282f8267c4495ee/john.jpg'}
    end

    context 'with grayscale filter' do
      let(:filters) { [{'grayscale' => ''}] }
      it {is_expected.to eq 'http://lvh.me:4000/731f70564f9145d79282f8267c4495ee/grayscale/john.jpg'}
    end

    context 'with grayscale filter and blur' do
      let(:filters) { [{'grayscale' => ''}, {'blur' => '1'}] }
      it {is_expected.to eq 'http://lvh.me:4000/731f70564f9145d79282f8267c4495ee/grayscale,blur-1/john.jpg'}
    end
  end

  describe 'image_path' do
    let(:uid) {'731f70564f9145d79282f8267c4495ee'}
    let(:image_name) {'john.jpg'}
    subject {client.image_path(uid, filters, image_name)}

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
    subject {client.merged_filters(filters)}

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
end
