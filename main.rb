require 'rubygems'
require 'simple-rss'
require 'open-uri'

blacklist = ['https://rainsoft.io/rss/']
year = 2016
month = 8
day = 31
posts = {}


def get_feed(url)
  begin
    timeout(10) do
      p "Trying #{url}"
      open(url)
    end
  rescue
    p "Failed to read: #{url}"
    nil
  end
end

def get_recent_posts(feed, year, month, day, collector)
  begin
    rss = SimpleRSS.parse feed
    blog_title = rss.channel.title
    p "Parsing feed articles from #{blog_title}"

    rss.items.each do |item|
      if item.pubDate.is_a?(Time) && (item.pubDate >= Time.new(year, month, day, 0, 0, 0)) && (item.pubDate <= Time.new(year, month, day, 23, 59, 59))
        p "Found Article: #{item.title}"
        collector[item.pubDate] = item
        collector[item.pubDate][:blog_title] = blog_title if blog_title
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
  next if blacklist.include? feed_url
  feed = get_feed(feed_url)
  get_recent_posts(feed, year, month, day, posts) if feed
end

p 'Creating contents'
contents = ''
posts.keys.compact.sort.reverse.each do |post_date|
  begin
    contents += "<p>#{posts[post_date][:blog_title]}: <a target='_blank' href='#{posts[post_date][:link]}'>#{posts[post_date][:title]}</a></p>"
  rescue
  end
end

p 'Writing file'
File.open("#{year}-#{month}-#{day}.html", 'w') { |file| file.write(contents) }
