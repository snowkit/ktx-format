# ktx-format

An unencumbered Haxe library to parse the [KTX texture file format from Khronos](https://www.khronos.org/opengles/sdk/tools/KTX/file_format_spec/).

## Using KTX-Textures
This library is pretty straightforward and supplies you with all the necessary information to forward the compressed data directly to opengl. There is little to no data processing necessary during load time which makes this a great addition/alternative to other common texture formats.

## Authoring KTX-Textures
Since KTX is all about compressed and uncompressed textureformats, you will need extra tools to author and review the textures. Thankfully there are quite a few useful commandline and GUI toolkits out there. A few of them are:
 * [PVRTexTool](https://community.imgtec.com/developers/powervr/tools/pvrtextool/) contains a set of GUI and cmdline utilities as well as plugins for 3Ds max, Maya and Photoshop
 * [cmftStudio](https://github.com/dariomanesku/cmftstudio) is a nice GUI tool to author all kinds of cubemaps
 * [cmft](https://github.com/dariomanesku/cmft) is the cmdline version of the aforementioned cmftStudio
