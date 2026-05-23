module BookLookup
  Result = Struct.new(
    :title,
    :author,
    :description,
    :cover_image,
    :isbn,
    :publisher,
    :published_at,
    :page_count,
    :categories,
    :source,
    :source_url,
    :confidence,
    :candidates,
    keyword_init: true
  )
end
