use ".."
use "collections"
use "json"
use "net"

// DEBUG
use "debug"
use "time"

actor SystemsHandler is Handler
  let _env: Env
  let _universe: Universe

  new create(env: Env, uni: Universe) =>
    _env = env
    _universe = uni

  be handle(conn: TCPConnection tag, req: JsonObject val) =>
    """Request should contain one of:
    - "id"
    - "name"
    - "nameQuery"
    The response is a JSON object describing the system, including a list of
    stations, as IDs by default, and with full details when "stationDetails" is
    true."""
    let t = Time.now()
    _env.out.print("Load balancer at " + t._1.string() +
        " seconds and " + t._2.string() + " nanos")

    let start = Time.now()
    let a = _SystemsRequest.create(_universe)
    let mid = Time.now()
    a.handle(conn, req)
    let done = Time.now()
    Debug("Time to build child actor: " + (mid._1 - start._1).string() +
        " seconds and " + (mid._2 - start._2).string() + " nanos")
    Debug("Time to call child actor: " + (done._1 - mid._1).string() +
        " seconds and " + (done._2 - mid._2).string() + " nanos")

actor _SystemsRequest is Handler
  let _universe: Universe val

  new create(uni: Universe val) =>
    _universe = uni

  be handle(conn: TCPConnection tag, req : JsonObject val) =>
    let start = Time.now()
    Debug("Request received at " + start._1.string() +
        " seconds and " + start._2.string() + " nanos")
    match try req.data("name") end
    | let s : String => _byName(s, conn, req); return
    end

    match try req.data("id") end
    | let id : I64 => _byId(id.u32(), conn, req); return
    end
    let done = Time.now()
    Debug("First two failed matches time: " + (done._1 - start._1).string() +
    " seconds and " + (done._2 - start._2).string() + " nanos")

    match try req.data("nameQuery") end
    | let s : String => _byNameQuery(s, conn, req); return
    end

  fun _byName(name: String, conn: TCPConnection tag, req: JsonObject val) =>
    try
      _send(_universe.systemsByName(name), conn, req)
    else
      conn.write("{\"error\": \"No system found named '" + name + "'\"}")
    end

  fun _byId(id: U32, conn: TCPConnection tag, req: JsonObject val) =>
    try
      _send(_universe.systemsById(id), conn, req)
    else
      conn.write("{\"error\": \"No system found for ID '" + id.string() + "'\"}")
    end

  fun _byNameQuery(query: String, conn: TCPConnection tag, req: JsonObject val) =>
    try
      let start = Time.now()
      var matches = Array[System val]()
      for s in _universe.systems.values() do
        if FuzzyMatch(query, s.name) then
          matches.push(s)
        end
      end
      let done = Time.now()
      Debug("Fuzzy matching search: " + (done._1 - start._1).string() +
      " seconds and " + (done._2 - start._2).string() + " nanos")

      if matches.size() > 1 then
        var msg = Map[String, JsonType]()
        msg("result") = "ambiguous"
        var names = Array[JsonType]()
        for s in matches.values() do names.push(s.name) end
        msg("matches") = JsonArray.from_array(names)

        conn.write(JsonObject.from_map(msg).string())
      elseif matches.size() == 0 then
        var msg = Map[String, JsonType]()
        msg("result") = "not_found"
        conn.write(JsonObject.from_map(msg).string())
      else // exactly 1
        _send(matches(0), conn, req)
      end
    else
      conn.write("""{ "error": "Error during fuzzy search" }""")
    end


  fun _send(sys: System val, conn: TCPConnection tag, req: JsonObject val) =>
    var json = sys.as_map()

    let details = match try req.data("stationDetails") end
      | true => true else false end

    let stationIds = try
      _universe.stationsBySystem(sys.id)
    else recover val Array[Station val] end end

    let uni = _universe
    let stations : JsonArray = recover
      var out = Array[JsonType]()
      for st in stationIds.values() do
        let v : JsonType = if details then st.json() else st.id.i64() end
        out.push(v)
      end
      JsonArray.from_array(out)
    end

    json("stations") = consume stations

    var msg = Map[String, JsonType]()
    msg("result") = "found"
    msg("system") = JsonObject.from_map(json)
    conn.write(JsonObject.from_map(msg).string())

