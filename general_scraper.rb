require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

def make_uri(ids)
  uri = 'http://example.com/path/to/target?'
  ids.each { |id| uri << id }
  uri << 'extra'
end

def get_ids
  File.open('ids.txt').read.chomp.split(',').map { |id| "#{id}&" }
end

def get_and_write_job_data
  ids = get_ids
  ids.each_slice(10) { |s| request_ids_and_write_to_file(s) }
end

def request_ids_and_write_to_file(ids)
  file = File.open('response.txt','a+')
  uri = make_uri(ids)
  response = open(uri, :allow_redirections => :safe)
  file.write(response.read)
  file.close
end

def get_targeted_data_from_html(r)
  tags = r.css('div.target').map do |t| 
    t.text.split("\n").reject { |e| e.empty? }}
  end

  targeted_data = tags.map do |t| 
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
    tag_counts[tag] = tag_counts[tag] + 1 }
  end
  tag_counts.sort_by { |k, v| -v }
end

def write_hash_to_file(hash, file)
  f = File.open(file, 'ab+')
  hash.each { |k, v| hash.write("#{k}: #{v}\n") }
end

def main
  get_and_write_job_data
  r = Nokogiri::HTML(File.open('response.txt').read)
  targeted_data = get_targeted_data_from_html(r)
  target_counts = count_targeted_data(targeted_data)
  write_hash_to_file(target_counts, 'sorted_target_data.txt')
end

main
