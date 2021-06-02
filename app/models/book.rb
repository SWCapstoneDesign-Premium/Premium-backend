require "selenium-webdriver"

class Book < ApplicationRecord
  included ImageUrl
  PERMIT_COLUMNS = [:title, :author, :content, :isbn, :publisher, :url, :image]

  # 책 없어지면, 챕터도 필요없는 것
  has_many :chapters, dependent: :destroy
  has_many :projects, dependent: :nullify

  def crawl_book_index
    Selenium::WebDriver::Chrome.driver_path = "/usr/local/bin/chromedriver"
    
    options = Selenium::WebDriver::Chrome::Options.new

    # headless는 브라우저를 띄우지 않고 진행하는 것임
    options.add_argument('--disable-extensions')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')

    wait = Selenium::WebDriver::Wait.new(timeout: 3) # dome loading을 위해 3초 대기
    
    @browser = Selenium::WebDriver.for :chrome, options: options

    
    @browser.navigate().to self.url

    wait.until { @browser.find_element(css: '#tabContent > .tab_body > .info_section > .coll_tit') }
    
    @content = @browser.find_elements(css: "#tabContent > .tab_body > .info_section > .coll_tit")

  
    @content.each do |dom|
      if dom.find_element(css: "h3.tit").text == "목차"
        @list_content = dom.find_element(xpath: "..").find_element(css: "p.desc").text
        break
      end
    end
    
    @browser.quit

    chapters = []

    @list_content.split("\n") do |chapter|
      chapters << Chapter.new(title: chapter, book: self) if chapter.present? # 띄어쓰기때문에 공백이 생김, 때문에 공백일 경우는 만들지 않도록 함
    end

    # bulk insert
    Chapter.import chapters

  end

end
