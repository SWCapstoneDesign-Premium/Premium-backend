class BookSerializer < Panko::Serializer
  attributes :title, :author, :content, :isbn, :publisher, :image, :id, :chapters

  def chapters
    context[:chapters] if context.present?
  end
end