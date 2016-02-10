primitive FuzzyMatch
  fun apply(query: ReadSeq[U8], source: ReadSeq[U8]) : Bool =>
    """Performs a fuzzy match of two strings. Order matters. This is
    effectively determining that the first argument is a subsequence of the
    second one."""
    var i : USize = 0
    var j : USize = 0
    try
      while (i < query.size()) and (j < source.size()) do
        if query(i) == source(j) then
          i = i + 1
        end
        j = j + 1
      end
      i == query.size()
    else
      false
    end

