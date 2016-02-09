use "time"

class val Price
  let commodity_id: U32
  let station_id: U32

  let supply: U32
  let demand: U32

  let buy: U32
  let sell: U32

  let collected_at: Date

  new val from_csv_row(s: String) =>
    let parts = s.split(",")
    station_id   = try s(1).u32() else 0 end
    commodity_id = try s(2).u32() else 0 end
    supply       = try s(3).u32() else 0 end
    buy          = try s(4).u32() else 0 end
    sell         = try s(5).u32() else 0 end
    demand       = try s(6).u32() else 0 end
    collected_at = Date(try s(7).i64() else 0 end)

  new val from_binary(arr: Array[U32] val, index: USize) =>
    station_id   = try arr(index)     else 0 end
    commodity_id = try arr(index + 1) else 0 end
    supply       = try arr(index + 2) else 0 end
    buy          = try arr(index + 3) else 0 end
    sell         = try arr(index + 4) else 0 end
    demand       = try arr(index + 5) else 0 end
    collected_at = Date(try arr(index + 6).i64() else 0 end)

