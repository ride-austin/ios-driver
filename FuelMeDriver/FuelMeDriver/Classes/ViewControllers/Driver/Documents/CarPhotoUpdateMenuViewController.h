//
//  CarPhotoUpdateMenuViewController.h
//  RideDriver
//
//  Created by Abdul Rehman on 08/11/2016.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseDocumentViewController.h"

@interface CarPhotoUpdateMenuViewController : BaseDocumentViewController

@property (weak, nonatomic) IBOutlet UICollectionView *carCollectionView;
@property (nonatomic,strong) NSString *carID;

@end
