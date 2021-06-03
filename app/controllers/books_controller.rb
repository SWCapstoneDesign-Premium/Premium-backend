class BooksController < ApiController
  before_action :authorize_check_request
  before_action :load_book, except: %i(index create get_list)
  
  def index
    @books = Book.all
    render json: each_serializer(@books, BookSerializer), status: :ok
  end
  
  def create
    begin
      @book = Book.find_or_create_by(title: book_params[:title])
      @book.update(book_params)
      render json: serializer(@book, BookSerializer), status: :ok
    rescue => exception
      render json: {errors: @book&.errors&.full_messages&.first}, status: :bad_request      
    end
  end

  def show
    begin
      render json: serializer(@book, BookSerializer), status: :ok
    rescue => exception
      render json: {errors: @book&.errors&.full_messages.first}, status: :not_found
    end
  end
  
  def destroy
    begin
      @book.destroy
      render json: { status: :ok }
    rescue => exception
      render json: {errors: @book&.errors&.full_messages.first}, status: :not_found
    end
  end

  def get_list # 목차 가져오기
    isbn = params.dig(:book, :isbn)
    book = Book.find_by(isbn: isbn)
    book.crawl_book_index if book.chapters.blank?
    render json: serializer(book, BookSerializer, { chapter: Book.find_by(isbn: isbn).chapters.order('id asc') } ), status: :ok
  end

  private

  def book_params
    params.require(:book).permit(Book::PERMIT_COLUMNS)
  end

  def load_book
    @book = Book.find(params[:id])
  end
end
