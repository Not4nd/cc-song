local args = {...}

if #args < 1 then
print("Usage: viewer <raw github url>")
return
end

local url = args[1]

print("Downloading image...")

local response = http.get(url)

if not response then
print("Failed to download file")
return
end

local file = fs.open("image.nfp", "w")
file.write(response.readAll())
file.close()
response.close()

print("Image saved.")

local img = paintutils.loadImage("image.nfp")

if not img then
print("Invalid NFP image")
return
end

local mon = peripheral.find("monitor")

if mon then
mon.setTextScale(0.5)
mon.setBackgroundColor(colors.black)
mon.clear()

```
term.redirect(mon)
paintutils.drawImage(img, 1, 1)
term.redirect(term.native())

print("Displayed on monitor.")
```

else
paintutils.drawImage(img, 1, 1)
print("Displayed on terminal.")
end
