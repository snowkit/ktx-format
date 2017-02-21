# ktx-format

An unencumbered Haxe library to parse the [KTX texture file format from Khronos](https://www.khronos.org/opengles/sdk/tools/KTX/file_format_spec/).

## Using KTX-Textures
This library is pretty straightforward and supplies you with all the necessary information to forward the texturedata directly to opengl. There is little to no data processing necessary during load time which makes this a great addition/alternative to other common texture formats.

## Authoring KTX-Textures
Since KTX is all about compressed and uncompressed textureformats, you will need extra tools to author and review the textures. Thankfully there are quite a few useful commandline and GUI toolkits out there. A few of them are:
 * [PVRTexTool](https://community.imgtec.com/developers/powervr/tools/pvrtextool/) contains a set of GUI and cmdline utilities as well as plugins for 3Ds max, Maya and Photoshop
 * [cmftStudio](https://github.com/dariomanesku/cmftstudio) is a nice GUI tool to author all kinds of cubemaps
 * [cmft](https://github.com/dariomanesku/cmft) is the cmdline version of the aforementioned cmftStudio

### Common Compression Formats Cheatsheet
This is a little helper to help me remember how the common formats relate to eachother

| old D3D | new D3D | OpenGL | OpenGL support |
|--- | --- | --- | --- |
| DXT1 | BC1 | S3TC | EXT_texture_compression_s3tc |
| DXT3 | BC2 | S3TC | EXT_texture_compression_s3tc |
| DXT5 |BC3 | S3TC | EXT_texture_compression_s3tc |
| ATI1 | BC4 | RGTC1 | 3.0 (or via extension) |
| ATI2 | BC5 | RGTC2 | 3.0 (or via extension) |
| - | BC6H | BPTC_FLOAT |	4.2 (or via extension) |
| - | BC7 | BPTC | 4.2 (or via extension) |
