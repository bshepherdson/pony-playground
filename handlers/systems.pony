use ".."
use "json"
use "net"

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
    _SystemsRequest.create(_universe).handle(conn, req)

actor _SystemsRequest is Handler
  let _universe: Universe val

  new create(uni: Universe val) =>
    _universe = uni

  be handle(conn: TCPConnection tag, req : JsonObject val) =>
    match try req.data("name") end
    | let s : String => _byName(s, conn, req); return
    end

    match try req.data("id") end
    | let id : I64 => _byId(id.u32(), conn, req); return
    end

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
    None
  fun _byNameQuery(query: String, conn: TCPConnection tag, req: JsonObject val) =>
    None

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
    conn.write(JsonObject.from_map(json).string())
