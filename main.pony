use "files"

actor Main
  new create(env: Env) =>
    let caps = recover val FileCaps.set(FileRead).set(FileStat) end
    try
      let stations = DataLoader.deserialize_file[Station](FilePath(env.root, "stations.json", caps))

      env.out.print("Loaded " + stations.size().string() +
          " stations, first one is called " + stations(0).name)
    end

