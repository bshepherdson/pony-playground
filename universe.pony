use "collections"

class val Universe
  """An immutable collection of information about the universe. Passed to the
  various request handlers to supply them with data."""
  let stations : Array[Station val] val
  let systems : Array[System val] val
  let commodities : Array[Commodity val] val
  let prices : Array[Price val] val

  let starmap : KDTree[F64, System val] val

  let systemsById : Map[U32, System val] val
  let systemsByName : Map[String, System val] val
  let stationsById : Map[U32, Station val] val
  let stationsByName : Map[String, Station val] val

  new create(st : Array[Station val] val, sy : Array[System val] val,
      cs : Array[Commodity val] val, ps : Array[Price val] val) =>
    stations = st
    systems = sy
    commodities = cs
    prices = ps

    // Also construct the several maps and indices:
    starmap = recover val
      var map = KDTree[F64, System val].create(3)
      try
        for v in sy.values() do
          map(recover val [v.x, v.y, v.z] end) = v
        end
      end
      map
    end

    (systemsById, systemsByName) = recover val
      var byId = Map[U32, System val]()
      var byName = Map[String, System val]()
      for v in sy.values() do
        byId(v.id) = v
        byName(v.name) = v
      end
      (byId, byName)
    end

    (stationsById, stationsByName) = recover val
      var byId = Map[U32, Station val]()
      var byName = Map[String, Station val]()
      for v in st.values() do
        byId(v.id) = v
        byName(v.name) = v
      end
      (byId, byName)
    end
