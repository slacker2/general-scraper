require 'net/http'
require 'nokogiri'
require 'open-url'
require 'open_url_redirections'

def make_url(ids)
  url = 'http://example.com/path/to/target?'
  ids.each { |id| url << id }
  url << 'extra'
end

def get_ids
  File.open('ids.txt').read.chomp.split(',').map { |id| "#{id}&" }
end

def get_and_write_job_data
  ids = get_ids
  ids.each_slice(10) { |s| request_ids_and_write_to_file(s) }
end

def request_ids_and_write_to_file(ids)
  file = File.open('response.txt', 'a+')
  url = make_url(ids)
  response = open(url, allow_redirections: :safe)
  file.write(response.read)
  file.close
end

def get_targeted_data_from_html(r)
  tags = r.css('div.target').map do |t|
    t.text.split("\n").reject { |e| e.empty? }
  end

  tags.map do |t|
    if t[2].nil?
      t[1].split('separator').map(&:strip).flatten
    else
      t[2].split('seperator').map(&:strip).flatten
    end
  end
end

def count_targeted_data(targeted_data)
  targeted_data.each do |tag|
    tag_counts[tag] ||= 0
    tag_counts[tag] = tag_counts[tag] + 1
  end
  tag_counts.sort_by { |k, v| -v }
end

def write_hash_to_file(hash, file)
  f = File.open(file, 'ab+')
  hash.each { |k, v| f.write("#{k}: #{v}\n") }
end

def main
  get_and_write_job_data
  r = Nokogiri::HTML(File.open('response.txt').read)
  targeted_data = get_targeted_data_from_html(r)
  target_counts = count_targeted_data(targeted_data)
  write_hash_to_file(target_counts, 'sorted_target_data.txt')
end

main
