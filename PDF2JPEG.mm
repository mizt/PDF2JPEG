#import <Cocoa/Cocoa.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_JPEG
namespace stb_image { 
	#import "stb_image_write.h" 
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		
		if(argc>=3) {
			
			NSString *src = [NSString stringWithFormat:@"%s",argv[1]];
			NSString *dst = [NSString stringWithFormat:@"%s",argv[2]];
			
			int quality = 100;
			float scale = 1.0;
			
			if(argc>=4) quality = [[NSString stringWithFormat:@"%s",argv[3]] intValue];
			if(argc>=5) {
				scale = [[NSString stringWithFormat:@"%s",argv[4]] floatValue];
				if(scale==0.0) return 1;
			}
						
			NSData *PDFData = [NSData dataWithContentsOfFile:src];
			
			NSPDFImageRep *PDFImgRep;
			PDFImgRep = [NSPDFImageRep imageRepWithData:PDFData];
			int pages = (int)[PDFImgRep pageCount];
			int width = PDFImgRep.size.width*scale;
			int height = PDFImgRep.size.height*scale;
			
			NSRect rect = NSMakeRect(0,0,width,height);
			
			unsigned int *pixels = new unsigned int[width*height];

			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGContextRef bitmapContext = CGBitmapContextCreate((unsigned char *)pixels,width,height,8,width*4,colorSpace,kCGImageAlphaPremultipliedFirst);
						
			int cnt = 0;
			
			for(int page=0; page<pages; page++) {
								
				[PDFImgRep setCurrentPage:page];
				
				NSImage *img = [[NSImage alloc] init];
				[img addRepresentation:PDFImgRep];
				
				NSGraphicsContext *graphicsContext = (NSGraphicsContext *)[[NSGraphicsContext currentContext] CGContext];
				CGImageRef cgImage = [img CGImageForProposedRect:&rect context:graphicsContext hints:nil];
				CGContextDrawImage(bitmapContext,NSRectToCGRect(rect),cgImage);
				
				for(int n=0; n<width*height; n++) {
					
					unsigned char alpha = (pixels[n]&0xFF);
					unsigned char r = (pixels[n]>>8)&0xFF;
					unsigned char g = (pixels[n]>>16)&0xFF;
					unsigned char b = (pixels[n]>>24)&0xFF;
					
					if(alpha==0xFF) {
						pixels[n] = alpha<<24|pixels[n]>>8;
					}
					else {
						float dry = alpha/255.0;
						float wet = 1.0-dry;
						pixels[n] = 0xFF000000|((unsigned char)(b*dry+255*wet))<<16|((unsigned char)(b*dry+255*wet))<<8|((unsigned char)(b*dry+255*wet));
					}
				}
				
				stb_image::stbi_write_jpg([[NSString stringWithFormat:@"%@/%05d.jpg",dst,page] UTF8String],width,height,4,(void const*)pixels,quality);
				
				cgImage = nil;
				img = nil;
			}
			
			CGContextRelease(bitmapContext);
			CGColorSpaceRelease(colorSpace);
			
			delete[] pixels;
		}
		else {
			NSLog(@"Usage: PDF2JPEG [input_file] [output_dir] <quality> <scale>");
			return 1;
		}
	}
	
	return 0;
}