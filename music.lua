local speaker = peripheral.find("speaker")

if not speaker then
    print("Speaker not found!")
    return
end

local dfpwm = require("cc.audio.dfpwm")
local PLAYLIST = "playlist.txt"

local function loadPlaylist()
    local songs = {}

    if fs.exists(PLAYLIST) then
        local f = fs.open(PLAYLIST, "r")

        while true do
            local line = f.readLine()
            if not line then break end

            local name, url = line:match("(.+)|(.+)")

            if name and url then
                table.insert(songs, {
                    name = name,
                    url = url
                })
            end
        end

        f.close()
    end

    return songs
end

local function savePlaylist(songs)
    local f = fs.open(PLAYLIST, "w")

    for _, song in ipairs(songs) do
        f.writeLine(song.name .. "|" .. song.url)
    end

    f.close()
end

local songs = loadPlaylist()

local function addSong()
    write("Name: ")
    local name = read()

    write("URL: ")
    local url = read()

    table.insert(songs, {
        name = name,
        url = url
    })

    savePlaylist(songs)

    print("Track added.")
end

local function listSongs()
    print()

    if #songs == 0 then
        print("Playlist empty.")
        return
    end

    for i, song in ipairs(songs) do
        print(i .. ". " .. song.name)
    end
end

local function deleteSong()
    listSongs()

    write("Number: ")
    local n = tonumber(read())

    if songs[n] then
        table.remove(songs, n)
        savePlaylist(songs)
        print("Deleted.")
    end
end

local function playSong(index)
    local song = songs[index]

    if not song then
        print("No such Track.")
        return
    end

    print("Downloading: " .. song.name)

    local response = http.get(song.url, nil, true)

    if not response then
        print("Download error.")
        return
    end

    local data = response.readAll()
    response.close()

    local filename = "temp.dfpwm"

    local f = fs.open(filename, "wb")
    f.write(data)
    f.close()

    print("Playing: " .. song.name)

    local decoder = dfpwm.make_decoder()
    local file = fs.open(filename, "rb")

    while true do
        local chunk = file.read(16 * 1024)

        if not chunk then
            break
        end

        local buffer = decoder(chunk)

        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end

    file.close()
end

while true do
    print()
    print("=== MUSIC PLAYER ===")
    print("1. Playlist")
    print("2. Add")
    print("3. Play")
    print("4. Delete")
    print("5. Exit")

    write("> ")
    local choice = read()

    if choice == "1" then
        listSongs()

    elseif choice == "2" then
        addSong()

    elseif choice == "3" then
        listSongs()

        write("Track number: ")
        local n = tonumber(read())

        playSong(n)

    elseif choice == "4" then
        deleteSong()

    elseif choice == "5" then
        break
    end
end
