local PLAYLIST = "playlist.txt"

local speakers = { peripheral.find("speaker") }

if #speakers == 0 then
    print("Mot found any Speaker!")
    return
end

local dfpwm = require("cc.audio.dfpwm")

local function loadPlaylist()
    local songs = {}

    if not fs.exists(PLAYLIST) then
        return songs
    end

    local f = fs.open(PLAYLIST, "r")

    while true do
        local line = f.readLine()

        if not line then
            break
        end

        local name, url = line:match("^(.-)|(.*)$")

        if name and url then
            table.insert(songs, {
                name = name,
                url = url
            })
        end
    end

    f.close()

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

local function deleteSong()
    if #songs == 0 then
        print("Playlist empty.")
        return
    end

    for i, song in ipairs(songs) do
        print(i .. ". " .. song.name)
    end

    write("Delete №: ")
    local n = tonumber(read())

    if songs[n] then
        table.remove(songs, n)
        savePlaylist(songs)
        print("Deleted.")
    end
end

local function listSongs()
    if #songs == 0 then
        print("Playlist empty.")
        return
    end

    for i, song in ipairs(songs) do
        print(i .. ". " .. song.name)
    end
end

local function download(url, fileName)
    local h = http.get(url, nil, true)

    if not h then
        return false
    end

    local f = fs.open(fileName, "wb")
    f.write(h.readAll())
    f.close()

    h.close()

    return true
end

local function playSong(song)
    print("Downloading...")
    
    if not download(song.url, "temp.dfpwm") then
        print("Error download.")
        return
    end

    print("Playing: " .. song.name)

    local decoder = dfpwm.make_decoder()
    local file = fs.open("temp.dfpwm", "rb")

    while true do
        local chunk = file.read(16 * 1024)

        if not chunk then
            break
        end

        local buffer = decoder(chunk)

        local played = false

        while not played do
            played = true

            for _, speaker in ipairs(speakers) do
                if not speaker.playAudio(buffer) then
                    played = false
                end
            end

            if not played then
                os.pullEvent("speaker_audio_empty")
            end
        end
    end

    file.close()

    print("Ready.")
end

while true do
    print()
    print("==== ExePlayer's PLAYER ====")
    print("Speakers: " .. #speakers)
    print("1. Playlist")
    print("2. Add track")
    print("3. Play")
    print("4. Delete track")
    print("5. Exit")
    print()

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

        if songs[n] then
            playSong(songs[n])
        end

    elseif choice == "4" then
        deleteSong()

    elseif choice == "5" then
        break
    end
end
