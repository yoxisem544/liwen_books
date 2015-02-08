require 'rest_client'
require 'nokogiri'
require 'json'
require 'iconv'
require 'uri'
require_relative 'course.rb'
# 難得寫註解，總該碎碎念。
class Spider
  attr_reader :semester_list, :courses_list, :query_url, :result_url

  def initialize
  	@query_url = "http://www.liwen.com.tw/pro_detail.php?item="
  end

  def prepare_post_data
    puts "hey yo bestwise here"
    nil
  end

  def get_books
  	# 初始 courses 陣列
    @books = []
    puts "getting books...\n"
    # 一一點進去YO

    503.times do |n|
      puts n+1
      r = RestClient.get @query_url + (n+1).to_s
      ic = Iconv.new("utf-8//translit//IGNORE", "utf-8")
      page = Nokogiri::HTML(ic.iconv(r.to_s))

      book_name = page.css('div.detail_proName').text
      unless book_name == ""
        author = page.css('div.detail_proInfo div.gray33').first.text
        translator = page.css('div.gray33:nth-of-type(2)').text
        publish = page.css('div.gray33:nth-of-type(3)').text
        publish_date = page.css('div.gray33:nth-of-type(4)').text
        isbn = page.css('div.gray33:nth-of-type(5)').text
        book_numder = page.css('div.gray33:nth-of-type(6)').text
        price = page.css('div:nth-of-type(15)').text
      end
      url = @query_url + (n+1).to_s


      # 100.times do |i|
      #   hi = 'div.gray33:nth-of-type('+i.to_s+')'
      #   puts "#{i}-----------\n--------------",page.css(hi)
      # end
      
      @books << Course.new({
        :book_name => book_name,
        :author => author,
        :translator => translator,
        :publish => publish,
        :publish_date => publish_date,
        :isbn => isbn,
        :book_numder => book_numder,
        :price => price,
        :url => url
        }).to_hash
    end
  end
  

  def save_to(filename='liwen_books.json') #now on page 2 part 3
    File.open(filename, 'w') {|f| f.write(JSON.pretty_generate(@books))}
  end
    
end






spider = Spider.new
spider.prepare_post_data
spider.get_books
spider.save_to