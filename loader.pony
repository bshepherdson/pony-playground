use "collections"
use "files"
use "json"
use "time"


interface FromJSON
  new from_json(obj: JsonObject)

primitive JsonLoader
  fun deserialize_file[A: FromJSON ref](fp : FilePath) : Array[A] =>
    """Reads a JSON file containing an array, and converts each to an A."""
    try
      let f = OpenFile(fp) as File
      let doc = _read_json_file(f)
      _deserialize_array[A](doc.data as JsonArray)
    else
      Array[A]()
    end

  fun _read_json_file(f: File) : JsonDoc ? =>
    var json = recover ref JsonDoc.create() end
    let bytes : Array[U8] val = f.read(f.size())
    let s : String val = recover val
      var r : String ref = String()
      r.append(bytes)
    end
    json.parse(s)
    json

  fun _deserialize_array[A: FromJSON ref](json : JsonArray) : Array[A] ? =>
    var out : Array[A] = Array[A]()
    for obj in json.data.values() do
      var jo : JsonObject ref = obj as JsonObject
      var st = A.from_json(jo)
      out.push(st)
    end
    out


primitive PriceLoader
  fun deserialize_prices(fp: FilePath) : Array[Price] ? =>
    var prices = Array[Price]()
    let records_per_block : USize = 16
    let record_size : USize = 7
    with f = OpenFile(fp) as File do
      let size = f.size()
      prices.reserve(size / (record_size * 4))
      let contents = @mmap[Pointer[U32]](USize(0), size,
          U32(1) /* PROT_READ */, U32(2) /* MAP_PRIVATE */, f.get_fd(),
          USize(0) /* offset */)
      let words = Array[U32].from_cstring(contents, size / 4)
      var i : USize = 0
      while i < words.size() do
        prices.push(Price.from_binary(words, i))
        i = i + record_size
      end
    end
    prices

