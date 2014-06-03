unzip = require "unzip"
walk = require "walk"
fs = require "fs"
path = require "path"

handleROMData = (stream, cb) ->
  console.log stream

readROMZip = (filename) ->
  fs.createReadStream(filename)
    .pipe(unzip.Parse())
    .on "entry", (entry) ->
      if entry.type.toLowerCase() == "file"
        if entry.path.match /\.nes$/i
          handleROMData entry, (err, res) ->
            throw err if err
      entry.autodrain()
    .on "error", (err) ->
      console.error("error unziping " + filename)

main = ->
  walker = walk.walk "/Users/kevin/Desktop/Nintendo/"
  walker.on "file", (root, fileStats, next) ->
    filename = path.join(root, fileStats.name)
    if filename.match /\.zip$/i
      readROMZip(filename)

    next()

  walker.on  "end", ->
    console.log "done"

if require.main == module
  main()
