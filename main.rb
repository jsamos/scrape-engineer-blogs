require 'rubygems'
require 'simple-rss'
require 'open-uri'

year = 2016
month = 8
day = 24
hour = 0
min = 0
sec = 0

opml_contents = open('https://raw.githubusercontent.com/kilimchoi/engineering-blogs/master/engineering_blogs.opml') {|f| f.read }
matches = opml_contents.scan(/xmlUrl=\".*?\"/)
  .map{|url_markup| url_markup.gsub!(/xmlUrl=\"/, '').gsub!(/\"/, '') }

p 'Collecting Articles'
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
      if item.pubDate.is_a?(Time) && (item.pubDate >= Time.new(year, month, day, hour, min, sec))
        p "Found Article: #{item.title}"
        posts[item.pubDate] = item
      end
    end
  rescue StandardError => e
    p "Failed to parse xml"
  end

end

contents = ''

posts.keys.compact.sort.reverse.each do |post_date|
  begin
    contents += "<p>#{posts[post_date][:pubDate]}: <a href='#{posts[post_date][:link]}'>#{posts[post_date][:title]}</a></p>"
  rescue
  end
end

File.open("#{year}-#{month}-#{day}.html", 'w') { |file| file.write(contents) }

