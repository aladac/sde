# frozen_string_literal: true

describe SDE::Downloader do
  let(:tmpdir) { Dir.mktmpdir('eve-sde-test') }

  after { FileUtils.rm_rf(tmpdir) }

  describe '#initialize' do
    it 'accepts url, zip_path, and extract_to' do
      dl = described_class.new(
        url: 'https://example.com/sde.zip',
        zip_path: File.join(tmpdir, 'sde.zip'),
        extract_to: File.join(tmpdir, 'extracted')
      )
      expect(dl).to be_a(described_class)
    end
  end

  describe '#call' do
    it 'creates directories and attempts download' do
      zip_path = File.join(tmpdir, 'sub', 'sde.zip')
      extract_to = File.join(tmpdir, 'out')

      dl = described_class.new(
        url: 'https://127.0.0.1:1/fake.zip',
        zip_path: zip_path,
        extract_to: extract_to
      )

      expect { dl.call }.to raise_error(StandardError)
      expect(Dir.exist?(File.dirname(zip_path))).to be true
      expect(Dir.exist?(extract_to)).to be true
    end
  end

  describe '#print_progress' do
    let(:dl) { described_class.new(url: 'https://example.com/sde.zip', zip_path: "#{tmpdir}/sde.zip", extract_to: tmpdir) }

    it 'prints percentage when total is known' do
      expect { dl.send(:print_progress, 524_288, 1_048_576) }.to output(/50\.0%/).to_stdout
    end

    it 'prints MB only when total is unknown' do
      expect { dl.send(:print_progress, 1_048_576, nil) }.to output(/1\.0MB/).to_stdout
    end
  end
end
