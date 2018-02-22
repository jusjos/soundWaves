//
//  ImageCombineViewController.m
//  CoreGraphicsWaveform
//
//  Created by Bangalore_CI on 2/13/18.
//  Copyright © 2018 Syed Haris Ali. All rights reserved.
//

#import "ImageCombineViewController.h"

@interface ImageCombineViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageCombineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImage *image1 = [UIImage imageNamed:@"20"];
    UIImage *image2 = [UIImage imageNamed:@"352"];
    //combining images
    
    //self.imageView.image = [self combinedImage:@[image1, image2, image1, image2]]; //[self combinedImage:image1 and:image2];
    
    //UIImage *blankImage = [[UIImage alloc] init];
    //CIImage *ciimage = [CIImage imageWithColor:[CIColor blueColor]];
    self.imageView.image = [self createBlankImage];
    
}


- (UIImage *)createBlankImage {
    CGSize imageSize = CGSizeMake(86, 256);
    UIColor *fillColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)combinedImage:(NSArray *)images {

    UIImage *sampleImage = (UIImage *)images[0];
    CGSize size = CGSizeMake(sampleImage.size.width * images.count, sampleImage.size.height);
    UIGraphicsBeginImageContext(size);
    CGFloat previousImageWidth = 0;
    for (UIImage *image in images) {
        CGFloat xcod = previousImageWidth;
        CGFloat ycod = 0;
        CGFloat width = image.size.width;
        CGFloat height = size.height;
        [image drawInRect:CGRectMake(xcod, ycod, width, height)];
        previousImageWidth += width;
    }
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

@end
