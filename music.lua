local speakers = { peripheral.find("speaker") }

if #speakers == 0 then
print("Колонки не найдены!")
return
end

local dfpwm = require("cc.audio.dfpwm")
local PLAYLIST = "playlist.txt"

local function loadPlaylist()
local songs = {}

```
if fs.exists(PLAYLIST) then
    local file = fs.open(PLAYLIST, "r")

    while true do
        local line = file.readLine()
        if not line then break end

        local name, url = line:match("(.+)|(.+)")
        if name and url then
            table.insert(songs, {
                name = name,
                url = url
            })
        end
    end

    file.close()
end

return songs
```

end

local function savePlaylist(songs)
local file = fs.open(PLAYLIST, "w")

```
for _, song in ipairs(songs) do
    file.writeLine(song.name .. "|" .. song.url)
end

file.close()
```

end

local songs = loadPlaylist()

local function listSongs()
print()

```
if #songs == 0 then
    print("Плейлист пуст.")
    return
end

for i, song in ipairs(songs) do
    print(i .. ". " .. song.name)
end
```

end

local function addSong()
write("Название: ")
local name = read()

```
write("URL: ")
local url = read()

table.insert(songs, {
    name = name,
    url = url
})

savePlaylist(songs)

print("Добавлено.")
```

end

local function deleteSong()
listSongs()

```
write("Номер: ")
local n = tonumber(read())

if songs[n] then
    table.remove(songs, n)
    savePlaylist(songs)
    print("Удалено.")
end
```

end

local function playSong(song)
print("Подключение...")

```
local response = http.get(song.url, nil, true)

if not response then
    print("Не удалось скачать трек.")
    return
end

print("Играет: " .. song.name)

local decoder = dfpwm.make_decoder()

while true do
    local chunk = response.read(16 * 1024)

    if not chunk then
        break
    end

    local buffer = decoder(chunk)

    local sent = false

    while not sent do
        sent = true

        for _, speaker in ipairs(speakers) do
            if not speaker.playAudio(buffer) then
                sent = false
            end
        end

        if not sent then
            os.pullEvent("speaker_audio_empty")
        end
    end
end

response.close()

print("Трек завершён.")
```

end

while true do
print()
print("=== MUSIC PLAYER ===")
print("1. Плейлист")
print("2. Добавить")
print("3. Играть")
print("4. Удалить")
print("5. Выход")

```
write("> ")
local choice = read()

if choice == "1" then

    listSongs()

elseif choice == "2" then

    addSong()

elseif choice == "3" then

    listSongs()

    write("Номер трека: ")
    local n = tonumber(read())

    if songs[n] then
        playSong(songs[n])
    end

elseif choice == "4" then

    deleteSong()

elseif choice == "5" then

    break
end
```

end
