use "collections"
use "files"
use "json"
use "time"


interface FromJSON
  new val from_json(obj: JsonObject val)

interface ToJSON
  fun as_map() : Map[String, JsonType]
  fun json() : JsonObject =>
    JsonObject.from_map(as_map())

primitive JsonLoader
  fun deserialize_file[A: FromJSON val](fp : FilePath) : Array[A] val =>
    """Reads a JSON file containing an array, and converts each to an A."""
    try
      let f = OpenFile(fp) as File
      let doc = _read_json_file(f)
      _deserialize_array[A](doc.data as JsonArray val)
    else
      recover val Array[A]() end
    end

  fun _read_json_file(f: File) : JsonDoc val ? =>
    let bytes : Array[U8] val = f.read(f.size())
    recover val
      var json = JsonDoc.create()
      let s : String val = recover val
        var r : String ref = String()
        r.append(bytes)
      end
      json.parse(s)
      json
    end

  fun _deserialize_array[A: FromJSON val](json : JsonArray val) : Array[A] val ? =>
    let data : Array[JsonType] val = json.data
    recover val
      var out : Array[A] = Array[A]()
      for obj in data.values() do
        let jo : JsonObject val = obj as JsonObject val
        out.push(A.from_json(jo))
      end
      out
    end


primitive PriceLoader
  fun deserialize_prices(fp: FilePath) : Array[Price val] val ? =>
    recover val
      var prices = Array[Price val]()
      let records_per_block : USize = 16
      let record_size : USize = 7
      with f = OpenFile(fp) as File do
        let size = f.size()
        let fd = f.get_fd()
        prices.reserve(size / (record_size * 4))
        let words = recover val
          let contents = @mmap[Pointer[U32]](USize(0), size,
              U32(1) /* PROT_READ */, U32(2) /* MAP_PRIVATE */, fd,
              USize(0) /* offset */)
          Array[U32].from_cstring(contents, size / 4)
        end
        var i : USize = 0
        while i < words.size() do
          prices.push(Price.from_binary(words, i))
          i = i + record_size
        end
      end
      prices
    end

