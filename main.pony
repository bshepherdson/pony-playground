use "collections"
use "files"

actor Main
  new create(env: Env) =>
    let caps = recover val FileCaps.set(FileRead).set(FileStat) end
    try
      let stations = JsonLoader.deserialize_file[Station val](
          FilePath(env.root, "data/stations.json", caps))
      let systems = JsonLoader.deserialize_file[System val](
          FilePath(env.root, "data/systems.json", caps))
      let commodities = JsonLoader.deserialize_file[Commodity val](
          FilePath(env.root, "data/commodities.json", caps))
      let prices = PriceLoader.deserialize_prices(
          FilePath(env.root, "data/listings.bin", caps))

      let universe = Universe.create(stations, systems, commodities, prices)

      env.out.print("Data loaded: " + systems.size().string() +
          " systems containing " + stations.size().string() +
          " stations selling " + commodities.size().string() +
          " commodities at " + prices.size().string() + " prices.")
    end

