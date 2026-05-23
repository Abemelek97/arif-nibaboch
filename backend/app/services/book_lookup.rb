module BookLookup
  def self.find(title:, author: nil)
    Finder.new(title:, author:, max_candidates: 1).find
  end
end
