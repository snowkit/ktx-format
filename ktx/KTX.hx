package ktx;

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;
import haxe.io.UInt8Array;
import haxe.io.UInt16Array;
import haxe.io.UInt32Array;


typedef KTXMipLevel = {
    var imageSize:Int;
    var faces:Array<BytesData>;
    var width:Int;
    var height:Int;
    var depth:Int;
};

typedef KTXData = {
    var glType:Int;
    var glTypeSize:Int;
    var glFormat:Int;
    var glInternalFormat:Int;
    var glBaseInternalFormat:Int;
    var pixelWidth:Int;
    var pixelHeight:Int;
    var pixelDepth:Int;
    var numberOfArrayElements:Int;
    var numberOfFaces:Int;
    var numberOfMipmapLevels:Int;
    var bytesOfKeyValueData:Int;
    var mips:Array<KTXMipLevel>;
    var compressed:Bool;
    var generateMips:Bool;
    var glTarget:Int;
    var dimensions:Int;
};

class KTX {
    // GL texture targets
    inline public static var GL_TEXTURE_1D:Int      = 0x0DE0;
    inline public static var GL_TEXTURE_2D:Int      = 0x0DE1;
    inline public static var GL_TEXTURE_3D:Int      = 0x806F;
    inline public static var GL_TEXTURE_CUBE_MAP:Int = 0x8513;

    public static function load(_bytes:Bytes):KTXData {
        var fin:BytesInput = new BytesInput(_bytes);

        var id = UInt8Array.fromBytes(_bytes, 0, 12);
        if (id[0] != 0xAB && id[1] != 0x4B && id[2] != 0x54 && id[3] != 0x58 &&
            id[4] != 0x20 && id[5] != 0x31 && id[6] != 0x31 && id[7] != 0xBB &&
            id[8] != 0x0D && id[9] != 0x0A && id[10] != 0x1A && id[11] != 0x0A)
            return null;
        fin.position = 12;

        // check endianess of data
        var e = fin.readInt32();
        if (e == 0x04030201)
            fin.bigEndian = false;
        else 
            fin.bigEndian = true;

        var ktx:KTXData = {
            glType:                 fin.readInt32(),
            glTypeSize:             fin.readInt32(),
            glFormat:               fin.readInt32(),
            glInternalFormat:       fin.readInt32(),
            glBaseInternalFormat:   fin.readInt32(),
            pixelWidth:             fin.readInt32(),
            pixelHeight:            fin.readInt32(),
            pixelDepth:             fin.readInt32(),
            numberOfArrayElements:  fin.readInt32(),
            numberOfFaces:          fin.readInt32(),
            numberOfMipmapLevels:   fin.readInt32(),
            bytesOfKeyValueData:    fin.readInt32(),
            mips: [],
            
            compressed: false,
            generateMips: false,
            glTarget: GL_TEXTURE_1D,
            dimensions: 1
        };

        fin.position += ktx.bytesOfKeyValueData;
        /* TODO: parse and type the key-value-data
        for (i in fin.position...(fin.position+ktx.bytesOfKeyValueData)) {
            var kvByteSize = fin.readInt32();
            var kv = Bytes.alloc(kvByteSize);
            fin.readFullBytes(kv, 0, kvByteSize);
            var padSize = 3 - ((kvByteSize + 3) % 4);
            var pad = Bytes.alloc(padSize);
            fin.readFullBytes(pad, 0, padSize);
        }
        */

        // run some validation
        if (ktx.glTypeSize != 1 && ktx.glTypeSize != 2 && ktx.glTypeSize != 4)
            throw "Unsupported glTypeSize \""+ktx.glTypeSize+"\".";
        
        if (ktx.glType == 0 || ktx.glFormat == 0) {
            if (ktx.glType + ktx.glFormat != 0)
                throw "glType and glFormat must be zero. Broken compression?";
            ktx.compressed = true;
        }

        if ((ktx.pixelWidth == 0) || (ktx.pixelDepth > 0 && ktx.pixelHeight == 0))
            throw "texture must have width or height if it has depth.";

        if (ktx.pixelHeight > 0) {
            ktx.dimensions = 2;
            ktx.glTarget = GL_TEXTURE_2D;
        }
        if (ktx.pixelDepth > 0) {
            ktx.dimensions = 3;
            ktx.glTarget = GL_TEXTURE_3D;
        }
        if (ktx.numberOfFaces == 6) {
            if (ktx.dimensions == 2)
                ktx.glTarget = GL_TEXTURE_CUBE_MAP;
            else
                throw "cubemap needs 2D faces.";
        }
        else if (ktx.numberOfFaces != 1)
            throw "numberOfFaces must be either 1 or 6";

        if (ktx.numberOfMipmapLevels == 0) {
            ktx.generateMips = true;
            ktx.numberOfMipmapLevels = 1;
        }

        // make sane defaults
        var pxDepth = ktx.pixelDepth > 0 ? ktx.pixelDepth : 1;
        var pxHeight = ktx.pixelHeight > 0 ? ktx.pixelHeight : 1;
        var pxWidth = ktx.pixelWidth > 0 ? ktx.pixelWidth : 1;
        
        for (i in 0...ktx.numberOfMipmapLevels) {
            var ml:KTXMipLevel = {
                imageSize: fin.readInt32(),
                faces: [],
                width: Std.int(Math.max(1, ktx.pixelWidth >> i)),
                height: Std.int(Math.max(1, ktx.pixelHeight >> i)),
                depth: Std.int(Math.max(1, ktx.pixelDepth >> i))
            }
            
            /* HACK-NOTE:
            Uncomment the following part if have trouble loading the last mips
            of a cubemap!
            if (ktx.numberOfFaces == 6 && i > 1 && ml.width == 1) {
                var w = ktx.mips[i-1].width;
                ml.imageSize = Std.int(ktx.mips[i-1].imageSize / (w*w));
            }
            */

            var imageSizeRounded = (ml.imageSize + 3)&~3;

            for (k in 0...ktx.numberOfFaces) {
                var data = Bytes.alloc(imageSizeRounded);
                fin.readFullBytes(data, 0, imageSizeRounded);
                ml.faces.push(data.getData());

                if (ktx.numberOfArrayElements > 0) {
                    if (ktx.dimensions == 2) ml.height = ktx.numberOfArrayElements;
                    if (ktx.dimensions == 3) ml.depth = ktx.numberOfArrayElements;
                }
            }

            ktx.mips.push(ml);
        }

        return ktx;
    }   
}
