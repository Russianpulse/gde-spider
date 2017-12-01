require 'bundler/setup'
require 'spidr'
require 'pry'
require 'readability'
require 'rchardet'


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

class ParsedPage
  def initialize(page)
    @page = page
  end

  def title
    @page.title
  end

  def text
    t = Readability::Document.new(@page.body).content

    t.force_encoding encoding(t)

    puts t.encoding

    t.encode Encoding::UTF_8
  end

  private

  def encoding(content)
    cd = CharDet.detect(content)
    confidence = cd['confidence'] # 0.0 <= confidence <= 1.0

    cd['encoding']
  end
end


storage = Storage.new

Spidr.site('http://www.warandpeace.ru/ru/') do |spider|
  spider.every_page do |page|
    puts page.url
    parsed = ParsedPage.new(page)
    storage.store page.url.to_s, title: parsed.title, text: parsed.text
  end
end
