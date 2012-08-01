//  ShinobiChart+Screenshot.h
//  Created by Stuart Grey on 22/02/2012.

#import <ShinobiCharts/ShinobiChart.h>
#import <ShinobiCharts/SChartCanvas.h>
#import "SChartGLView+Screenshot.h"

@interface ShinobiChart (Screenshot)

- (UIImage*)snapshot;

@end


@implementation ShinobiChart (Screenshot)

- (UIImage*)snapshot {
    
    CGRect glFrame = self.canvas.glView.frame;
    glFrame.origin.y = self.canvas.frame.origin.y;
    
    //Grab the GL screenshot
    UIImage *glImage = [self.canvas.glView snapshot];
    UIImageView *glImageView = [[UIImageView alloc] initWithFrame:glFrame];
    [glImageView setImage:glImage];
        
    //Grab the chart image (minus GL)
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.frame.size);    
    }
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *chartImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Turn the chart image into a view and to create the composite
    UIImageView *chartImageView = [[UIImageView alloc] initWithFrame:self.frame];
    [chartImageView setImage:chartImage];
    
    //Add our GL capture to our chart capture
    [chartImageView addSubview:glImageView];
    
    //Turn our composite into a single image
    UIGraphicsBeginImageContext(chartImageView.bounds.size);
    [chartImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *completeChartImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return completeChartImage;
    
}

@end
