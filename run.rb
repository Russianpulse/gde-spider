require 'bundler/setup'
require 'spidr'
require 'pry'
require 'readability'

class Storage
  PATH = './data'

  def store(url, data)
    File.open(filename(url), 'w') do |f|
      f.write data[:title]
      f.write data[:text]
    end
  end

  private

  def filename(url)
    File.join(PATH, Digest::SHA256.hexdigest(url) )
  end
end

class PageParser
  def parse(page)
    {
      title: page.title,
      text: Readability::Document.new(page.body).content
    }
  end
end


storage = Storage.new
parser = PageParser.new

Spidr.site('http://www.warandpeace.ru/ru/') do |spider|
  spider.every_page do |page|
    puts page.url
    data = parser.parse page
    storage.store page.url.to_s, data
  end
end
