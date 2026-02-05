# frozen_string_literal: true

require "net/http"
require "uri"
require "fileutils"

class SDE::Downloader
  def initialize(url:, zip_path:, extract_to:)
    @url = url
    @zip_path = Pathname.new(zip_path)
    @extract_to = Pathname.new(extract_to)
  end

  def call
    FileUtils.mkdir_p(@zip_path.dirname)
    FileUtils.mkdir_p(@extract_to)

    download
    extract
  end

  private

  def download
    puts "Downloading #{@url}..."
    uri = URI(@url)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request) do |response|
        handle_response(response, uri)
      end
    end
  end

  def handle_response(response, uri)
    case response
    when Net::HTTPRedirection
      raise "Redirect to #{URI(response["location"])} — re-run or update URL"
    when Net::HTTPSuccess
      write_with_progress(response)
    else
      abort "Download failed: #{response.code} #{response.message}"
    end
  end

  def write_with_progress(response)
    total = response["content-length"]&.to_i
    downloaded = 0

    File.open(@zip_path, "wb") do |f|
      response.read_body do |chunk|
        f.write(chunk)
        downloaded += chunk.size
        print_progress(downloaded, total)
      end
    end
    puts
  end

  def print_progress(downloaded, total)
    mb = (downloaded / 1_048_576.0).round(1)
    if total
      pct = (downloaded * 100.0 / total).round(1)
      print "\r  #{pct}% (#{mb}MB)"
    else
      print "\r  #{mb}MB"
    end
  end

  def extract
    puts "Extracting to #{@extract_to}..."
    system("unzip", "-o", "-q", @zip_path.to_s, "-d", @extract_to.to_s) || abort("unzip failed")
    puts "Done. YAML files in #{@extract_to}"
  end
end
