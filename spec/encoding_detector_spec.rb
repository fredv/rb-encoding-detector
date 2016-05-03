require 'spec_helper'
require_relative '../../lib/encoding_detector'
require 'charlock_holmes'
require 'rchardet'

  def test_cases
    {
      "spec/support/files/security.de.yml" => %w(UTF-8),
      "spec/support/files/huge_translation.txt" => %w(ISO-8859-1 ascii), # ASCII 8Bit, Extended ASCII, includes ASCII 7bit
      "spec/support/files/strings.csv" => %w(UTF-16LE),
      "spec/support/files/utf-16-xcode.strings" =>   %w(UTF-16BE),
      "spec/support/files/utf-16be-bom.yml" => %w(UTF-16BE),
      "spec/support/files/utf-16be.yml" => %w(UTF-16BE),
      "spec/support/files/utf-16le-bom.yml" => %w(UTF-16LE),
      "spec/support/files/utf-16le.yml" => %w(UTF-16LE)
    }
  end

describe "Encoding libraries" do
  context "EncodingDetector" do
    test_cases.each do |file, encoding|
      describe "#{file}" do
        specify do
          input = File.read(file)
          expect(encoding).to include(EncodingDetector.new.detect(input, prefer_utf8: false))
        end
      end
    end
  end
  
  context "CharlockHolmes" do
    test_cases.each do |file, encoding|
      describe "#{file}" do
        specify do
          input = File.read(file)
          detection = CharlockHolmes::EncodingDetector.detect(input)
          puts detection.inspect
          puts "CharlockHolmes detected #{detection[:encoding]} with Confidence: #{detection[:confidence]}"
          expect(encoding).to include(detection[:encoding])
        end
      end
    end
  end

  context 'RCharDet' do
    test_cases.each do |file, encoding|
      describe "#{file}" do
        specify do
          input = File.read(file)
          detection = CharDet.detect(input)
          puts "RCharDet detected #{detection} with Confidence: #{detection['confidence']}"
          expect(encoding).to include(detection['encoding'])
        end
      end
    end
  end

  context '$ file info' do
    test_cases.each do |file, encoding|
      describe "#{file}" do
        specify do
          out = `file #{file}|awk '{ print $2" "$3 }'`.strip
          detected = nil
          {
            "UTF-8 Unicode" => "UTF-8",
            "ASCII" => "ascii",
            "Big-endian UTF-16" => "UTF-16BE",
            "Little-endian UTF-16" => "UTF-16LE",
          }.each do |key, value|
            if out =~ /#{key}/
              detected = value
            end
          end
          detected ||= out
          expect(encoding).to include(detected)
        end        
      end
    end
  end
end
