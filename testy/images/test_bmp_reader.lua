package.path = "../?.lua;"..package.path;

local bmp = require("lj2media.imgage_bmp")
local binstream = require("binstream")
local mmap = require("mmap")
local bitbang = require("lj2media.bitbang")
local BVALUE = bitbang.BITSVALUE
local spairs = require("spairs")
local fourcc = require("lj2media.fourcc")
local fourccToString = fourcc.fourccToString

local function BYTEVALUE(x, low, high)
    return tonumber(BVALUE(x, low, high))
end



local function printDict(dict)
    print("==== Chunk ====")
    for k,v in spairs(dict) do
        if k == "Id" or k == "Kind" or k == "fcc" then
            v = fourccToString(v)
        elseif k == "FormatTag" then
            v = string.format("0x%x", v)
        end

        print(string.format("%-10s: ", k),v)
    end
end



local function printFileHeader(header)
    print("==== File Header ====")
    print("ID: ", fourccToString(header.Id))
    print("Size: ", header.Size)
    print("Kind: ", fourccToString(header.Kind))
end

local function printChunk(chunk)
    print("==== CHUNK ====")
    print("ID: ", fourccToString(chunk.Id))
    print("Size: ", string.format("0x%x",chunk.Size))
    print("Data: ", chunk.Data)
end


local function readFromFile(filename)
    print("++++======= FILE: ", filename)
    local filemap, err = mmap(filename)
    if not filemap then
        return false, "file not mapped ()"..tostring(err)
    end

    local bs, err = binstream(filemap:getPointer(), filemap:length(), 0, true )

    if not bs then
        return false, err
    end

    local header = riff.readFileHeader(bs)

    printFileHeader(header)

    -- create subrange for those cases where the file is bigger
    -- than the RIFF chunk
    local ls, err = bs:range(header.Size-4)
    if not ls then
        print("bs:range(), failure: ", err)
        return false;
    end

    for chunk in riff.readChunks(ls, header) do
        --printChunk(chunk)
        printDict(chunk)
    end
end



local files = {
    "badbitcount.bmp",
    "badbitssize.bmp",
    "baddens1.bmp",
    "baddens2.bmp",
    "badfilesize.bmp",
    "badheadersize.bmp",
    "badpalettesize.bmp",
    "badplanes.bmp",
    "badrle.bmp",
    "badrle4.bmp",
    "badrle4bis.bmp",
    "badrle4ter.bmp",
    "badrlebis.bmp",
    "badrleter.bmp",
    "badwidth.bmp",

    "pal8badindex.bmp",
    "reallybig.bmp",
    "rgb16-880.bmp",
    "rletopdown.bmp",
    "shortfile.bmp",

}

for _, filename in ipairs(files) do
    readFromFile(string.format("images\\bmp\\%s", filename))
end

