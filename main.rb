require 'rubygems'
require 'simple-rss'
require 'open-uri'

year = 2016
month = 8
day = 24
hour = 0
posts = {}


def get_feed(url)
  begin
    timeout(3) do
      p "Trying #{url}"
      open(url)
    end
  rescue
    p "Failed to read: #{url}"
  end
end

def get_recent_posts(feed, year, month, day, hour, collector)
  begin
    p "Parsing feed articles"
    rss = SimpleRSS.parse feed

    rss.items.each do |item|
      if item.pubDate.is_a?(Time) && (item.pubDate >= Time.new(year, month, day, hour, 0, 0))
        p "Found Article: #{item.title}"
        collector[item.pubDate] = item
      end
    end
  rescue StandardError => e
    p "Failed to parse xml"
  end
end

opml_contents = open('https://raw.githubusercontent.com/kilimchoi/engineering-blogs/master/engineering_blogs.opml') {|f| f.read }
matches = opml_contents.scan(/xmlUrl=\".*?\"/)
  .map{|url_markup| url_markup.gsub!(/xmlUrl=\"/, '').gsub!(/\"/, '') }

p 'Collecting Articles'
matches[2..-1].each do |feed_url|
  feed = get_feed(feed_url)
  get_recent_posts(feed, year, month, day, hour, posts)
end

p 'Creating contents'
contents = ''
posts.keys.compact.sort.reverse.each do |post_date|
  begin
    contents += "<p>#{posts[post_date][:pubDate]}: <a href='#{posts[post_date][:link]}'>#{posts[post_date][:title]}</a></p>"
  rescue
  end
end

p 'Writing file'
File.open("#{year}-#{month}-#{day}.html", 'w') { |file| file.write(contents) }

