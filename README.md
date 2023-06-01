# PDF2JPEG

#### build

[stb_image_write.h](https://github.com/nothings/stb/blob/master/stb_image_write.h) required.

```
$ xcrun clang++ -ObjC++ -O3 -std=c++20 -Wc++20-extensions ./PDF2JPEG.mm -fobjc-arc -framework Cocoa -o PDF2JPEG
```

#### usage

```
$ PDF2JPEG [input_file] [output_dir] <quality> <scale>
```
`quality`  0~100 (default value is 100)    
`scale` default value is 1.0