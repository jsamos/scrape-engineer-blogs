require 'rubygems'
require 'simple-rss'
require 'open-uri'

opml_contents = open('https://raw.githubusercontent.com/kilimchoi/engineering-blogs/master/engineering_blogs.opml') {|f| f.read }
matches = opml_contents.scan(/xmlUrl=\".*?\"/)
  .map{|url_markup| url_markup.gsub!(/xmlUrl=\"/, '').gsub!(/\"/, '') }

p 'Collecting Feeds'
feeds = []
posts = {}
matches[2..-1].each do |feed_url|
  begin
    p "Trying #{feed_url}"
    timeout(3) do
      feeds << open(feed_url)
    end
  rescue
    p "Failed to read: #{feed_url}"
  end
end

feeds.each do |feed|
  begin
    p "Parsing xml"
    rss = SimpleRSS.parse feed

    rss.items.each do |item|
      posts[item.pubDate] = item if item.pubDate.is_a?(Time) && (item.pubDate >= Time.new(2016, 8, 24, 0, 0, 0))
    end
  rescue StandardError => e
    p "Failed to parse xml"
  end

end

posts.keys.compact.sort.reverse.each do |post_date|
  begin
    p posts[post_date][:title]
    p posts[post_date][:link]
    p posts[post_date][:pubDate]
  rescue
  end
end


# rss = SimpleRSS.parse open('http://nerds.airbnb.com/feed')
# posts = {}
#
# p rss.channel.title
# p rss.channel.link
#
# rss.items.each do |item|
#   p item.title
#   p item.link
#   p item.pubDate
#   p item.description
# end
