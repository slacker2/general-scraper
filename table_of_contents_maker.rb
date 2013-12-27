# This script was used to output the markdown for a table of contents for
# a manual for a github project I was looking at. Nothing exciting.

require 'net/http'
require 'nokogiri'
require 'open-uri'

def main
  source_html = open('https://github.com/louismullie/treat/wiki/Manual')
  n = Nokogiri::HTML(source_html.read)
  anchor_tags = n.css('div#wiki-content a.anchor')
  index = build_index_for_anchor_tags(anchor_tags)
end

def build_index_for_anchor_tags(anchor_tags)
  index = ''
  anchor_tags.each { |anchor_tag| index = index + make_li(anchor_tag) }
  puts index
end

def make_li(anchor)

  # Hacked because lack of uniformity in wiki styles
  li = anchor.parent.name == 'h3' ? ' '*4 : ''

  #NOTE: I added 'Manual' because of this issue:
  #          https://github.com/gollum/gollum/issues/666
  #      Prepending the page shouldn't be necessary.
  li = li + %(* [#{anchor.parent.text.strip}](Manual#{anchor.get_attribute('href')})\n)
end

main

