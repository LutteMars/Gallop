




/********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
/***************  https://github.com/waynezxcv/Gallop 持续更新 ***************************/
/******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/




#import "CellLayout.h"
#import "LWTextParser.h"
#import "CommentModel.h"
#import "Gallop.h"


@implementation CellLayout

- (id)initWithStatusModel:(StatusModel *)statusModel
                    index:(NSInteger)index
            dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self) {
        self.statusModel = statusModel;
        /****************************生成Storage 相当于模型*************************************/
        /*********Gallop用将所有文本跟图片的模型都抽象成LWStorage，方便你能预先将所有的需要计算的布局内容直接缓存起来***/
        /*******而不是在渲染的时候才进行计算*******************************************/
        //头像模型 avatarImageStorage
        LWImageStorage* avatarStorage = [[LWImageStorage alloc] initWithIdentifier:@"avatar"];
        avatarStorage.contents = statusModel.avatar;
        avatarStorage.cornerRadius = 20.0f;
        avatarStorage.cornerBackgroundColor = [UIColor whiteColor];
        avatarStorage.backgroundColor = RGB(240, 240, 240, 1);
        avatarStorage.frame = CGRectMake(10, 20, 40, 40);
        avatarStorage.tag = 9;
        avatarStorage.cornerBorderWidth = 1.0f;
        avatarStorage.cornerBorderColor = RGB(113, 129, 161, 1);

        //名字模型 nameTextStorage
        LWTextStorage* nameTextStorage = [[LWTextStorage alloc] init];
        nameTextStorage.text = statusModel.name;
        nameTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        nameTextStorage.frame = CGRectMake(60.0f, 20.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        [nameTextStorage lw_addLinkWithData:[NSString stringWithFormat:@"%@",statusModel.name]
                                      range:NSMakeRange(0,statusModel.name.length)
                                  linkColor:RGB(113, 129, 161, 1)
                             highLightColor:RGB(0, 0, 0, 0.15)];

        //正文内容模型 contentTextStorage
        LWTextStorage* contentTextStorage = [[LWTextStorage alloc] init];
        contentTextStorage.text = statusModel.content;
        contentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:15.0f];
        contentTextStorage.textColor = RGB(40, 40, 40, 1);
        contentTextStorage.frame = CGRectMake(nameTextStorage.left, nameTextStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        [LWTextParser parseEmojiWithTextStorage:contentTextStorage];
        [LWTextParser parseTopicWithLWTextStorage:contentTextStorage
                                        linkColor:RGB(113, 129, 161, 1)
                                   highlightColor:RGB(0, 0, 0, 0.15)];
        //发布的图片模型 imgsStorage
        CGFloat imageWidth = (SCREEN_WIDTH - 110.0f)/3.0f;
        NSInteger imageCount = [statusModel.imgs count];
        NSMutableArray* imageStorageArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        NSMutableArray* imagePositionArray = [[NSMutableArray alloc] initWithCapacity:imageCount];
        if ([self.statusModel.type isEqualToString:@"image"]) {
            NSInteger row = 0;
            NSInteger column = 0;
            if (imageCount == 1) {
                CGRect imageRect = CGRectMake(nameTextStorage.left,
                                              contentTextStorage.bottom + 5.0f + (row * (imageWidth + 5.0f)),
                                              imageWidth*1.7,
                                              imageWidth*1.7);
                NSString* imagePositionString = NSStringFromCGRect(imageRect);
                [imagePositionArray addObject:imagePositionString];
                LWImageStorage* imageStorage = [[LWImageStorage alloc] initWithIdentifier:@"image"];
                imageStorage.tag = 0;
                imageStorage.clipsToBounds = YES;
                imageStorage.frame = imageRect;
                imageStorage.backgroundColor = RGB(240, 240, 240, 1);
                NSString* URLString = [statusModel.imgs objectAtIndex:0];
                imageStorage.contents = [NSURL URLWithString:URLString];
                [imageStorageArray addObject:imageStorage];
            } else {
                for (NSInteger i = 0; i < imageCount; i ++) {
                    CGRect imageRect = CGRectMake(nameTextStorage.left + (column * (imageWidth + 5.0f)),
                                                  contentTextStorage.bottom + 5.0f + (row * (imageWidth + 5.0f)),
                                                  imageWidth,
                                                  imageWidth);
                    NSString* imagePositionString = NSStringFromCGRect(imageRect);
                    [imagePositionArray addObject:imagePositionString];
                    LWImageStorage* imageStorage = [[LWImageStorage alloc] initWithIdentifier:@"image"];
                    imageStorage.clipsToBounds = YES;
                    imageStorage.tag = i;
                    imageStorage.frame = imageRect;
                    imageStorage.backgroundColor = RGB(240, 240, 240, 1);
                    NSString* URLString = [statusModel.imgs objectAtIndex:i];
                    imageStorage.contents = [NSURL URLWithString:URLString];
                    [imageStorageArray addObject:imageStorage];
                    column = column + 1;
                    if (column > 2) {
                        column = 0;
                        row = row + 1;
                    }
                }
            }

        }
        else if ([self.statusModel.type isEqualToString:@"website"]) {
            self.websiteRect = CGRectMake(nameTextStorage.left,contentTextStorage.bottom + 5.0f,SCREEN_WIDTH - 80.0f,60.0f);

            LWImageStorage* imageStorage = [[LWImageStorage alloc] init];
            NSString* URLString = [statusModel.imgs objectAtIndex:0];
            imageStorage.contents = [NSURL URLWithString:URLString];
            imageStorage.clipsToBounds = YES;
            imageStorage.frame = CGRectMake(nameTextStorage.left + 5.0f, contentTextStorage.bottom + 10.0f , 50.0f, 50.0f);
            [imageStorageArray addObject:imageStorage];

            LWTextStorage* detailTextStorage = [[LWTextStorage alloc] init];
            detailTextStorage.text = statusModel.detail;
            detailTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
            detailTextStorage.textColor = RGB(40, 40, 40, 1);
            detailTextStorage.frame = CGRectMake(imageStorage.right + 10.0f, contentTextStorage.bottom + 10.0f, SCREEN_WIDTH - 150.0f, 60.0f);
            detailTextStorage.linespacing = 0.5f;
            [detailTextStorage lw_addLinkForWholeTextStorageWithData:@"https://github.com/waynezxcv/LWAlchemy" linkColor:nil highLightColor:RGB(0, 0, 0, 0.15)];
            [self addStorage:detailTextStorage];
        }
        else if ([self.statusModel.type isEqualToString:@"video"]) {

        }
        //获取最后一张图片的模型
        LWImageStorage* lastImageStorage = (LWImageStorage *)[imageStorageArray lastObject];
        //生成时间的模型 dateTextStorage
        LWTextStorage* dateTextStorage = [[LWTextStorage alloc] init];
        dateTextStorage.text = [dateFormatter stringFromDate:statusModel.date];
        dateTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        dateTextStorage.textColor = [UIColor grayColor];
        //菜单按钮
        CGRect menuPosition;
        if (lastImageStorage) {
            menuPosition = CGRectMake(SCREEN_WIDTH - 54.0f,10.0f + lastImageStorage.bottom - 14.5f,44,44);
            dateTextStorage.frame = CGRectMake(nameTextStorage.left, lastImageStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);

        } else {
            menuPosition = CGRectMake(SCREEN_WIDTH - 54.0f,10.0f + contentTextStorage.bottom  - 14.5f ,44,44);
            dateTextStorage.frame = CGRectMake(nameTextStorage.left, contentTextStorage.bottom + 10.0f, SCREEN_WIDTH - 80.0f, CGFLOAT_MAX);
        }
        //生成评论背景Storage
        LWImageStorage* commentBgStorage = [[LWImageStorage alloc] init];
        NSArray* commentTextStorages = @[];
        CGRect commentBgPosition = CGRectZero;
        CGRect rect = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, 20);
        CGFloat offsetY = 0.0f;
        //点赞
        LWImageStorage* likeImageSotrage = [[LWImageStorage alloc] init];
        LWTextStorage* likeTextStorage = [[LWTextStorage alloc] init];
        if (self.statusModel.likeList.count != 0) {
            likeImageSotrage.contents = [UIImage imageNamed:@"Like"];
            likeImageSotrage.frame = CGRectMake(rect.origin.x + 10.0f,rect.origin.y + 10.0f + offsetY,16.0f, 16.0f);
            NSMutableString* mutableString = [[NSMutableString alloc] init];
            NSMutableArray* composeArray = [[NSMutableArray alloc] init];
            int rangeOffset = 0;
            for (NSInteger i = 0;i < self.statusModel.likeList.count; i ++) {
                NSString* liked = self.statusModel.likeList[i];
                [mutableString appendString:liked];
                NSRange range = NSMakeRange(rangeOffset, liked.length);
                [composeArray addObject:[NSValue valueWithRange:range]];
                rangeOffset += liked.length;
                if (i != self.statusModel.likeList.count - 1) {
                    NSString* dotString = @",";
                    [mutableString appendString:dotString];
                    rangeOffset += 1;
                }
            }
            likeTextStorage.text = mutableString;
            likeTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
            likeTextStorage.frame = CGRectMake(likeImageSotrage.right + 5.0f, rect.origin.y + 7.0f, SCREEN_WIDTH - 110.0f, CGFLOAT_MAX);
            for (NSValue* rangeValue in composeArray) {
                NSRange range = [rangeValue rangeValue];
                CommentModel* commentModel = [[CommentModel alloc] init];
                commentModel.to = [likeTextStorage.text substringWithRange:range];
                commentModel.index = index;
                [likeTextStorage lw_addLinkWithData:commentModel range:range linkColor:RGB(113, 129, 161, 1) highLightColor:RGB(0, 0, 0, 0.15)];
            }
            offsetY += likeTextStorage.height + 5.0f;
        }
        if (statusModel.commentList.count != 0 && statusModel.commentList != nil) {
            if (self.statusModel.likeList.count != 0) {
                self.lineRect = CGRectMake(nameTextStorage.left, likeTextStorage.bottom + 2.5f,  SCREEN_WIDTH - 80, 0.1f);
            }
            NSMutableArray* tmp = [[NSMutableArray alloc] initWithCapacity:statusModel.commentList.count];
            for (NSDictionary* commentDict in statusModel.commentList) {
                NSString* to = commentDict[@"to"];
                if (to.length != 0) {
                    NSString* commentString = [NSString stringWithFormat:@"%@回复%@:%@",commentDict[@"from"],commentDict[@"to"],commentDict[@"content"]];
                    LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                    commentTextStorage.text = commentString;
                    commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);

                    CommentModel* commentModel1 = [[CommentModel alloc] init];
                    commentModel1.to = commentDict[@"from"];
                    commentModel1.index = index;
                    [commentTextStorage lw_addLinkForWholeTextStorageWithData:commentModel1 linkColor:nil highLightColor:RGB(0, 0, 0, 0.15)];

                    [commentTextStorage lw_addLinkWithData:commentModel1
                                                     range:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];

                    CommentModel* commentModel2 = [[CommentModel alloc] init];
                    commentModel2.to = [NSString stringWithFormat:@"%@",commentDict[@"to"]];
                    commentModel2.index = index;
                    [commentTextStorage lw_addLinkWithData:commentModel2
                                                     range:NSMakeRange([(NSString *)commentDict[@"from"] length] + 2,[(NSString *)commentDict[@"to"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];

                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)];
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                } else {
                    NSString* commentString = [NSString stringWithFormat:@"%@:%@",commentDict[@"from"],commentDict[@"content"]];
                    LWTextStorage* commentTextStorage = [[LWTextStorage alloc] init];
                    commentTextStorage.text = commentString;
                    commentTextStorage.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
                    commentTextStorage.textAlignment = NSTextAlignmentLeft;
                    commentTextStorage.linespacing = 2.0f;
                    commentTextStorage.textColor = RGB(40, 40, 40, 1);
                    commentTextStorage.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + 10.0f + offsetY,SCREEN_WIDTH - 95.0f, CGFLOAT_MAX);

                    CommentModel* commentModel = [[CommentModel alloc] init];
                    commentModel.to = commentDict[@"from"];
                    commentModel.index = index;
                    [commentTextStorage lw_addLinkForWholeTextStorageWithData:commentModel linkColor:nil highLightColor:RGB(0, 0, 0, 0.15)];
                    [commentTextStorage lw_addLinkWithData:commentModel
                                                     range:NSMakeRange(0,[(NSString *)commentDict[@"from"] length])
                                                 linkColor:RGB(113, 129, 161, 1)
                                            highLightColor:RGB(0, 0, 0, 0.15)];

                    [LWTextParser parseTopicWithLWTextStorage:commentTextStorage
                                                    linkColor:RGB(113, 129, 161, 1)
                                               highlightColor:RGB(0, 0, 0, 0.15)];
                    [LWTextParser parseEmojiWithTextStorage:commentTextStorage];
                    [tmp addObject:commentTextStorage];
                    offsetY += commentTextStorage.height;
                }
            }
            //如果有评论，设置评论背景Storage
            commentTextStorages = tmp;
            commentBgPosition = CGRectMake(60.0f,dateTextStorage.bottom + 5.0f, SCREEN_WIDTH - 80, offsetY + 15.0f);
            commentBgStorage.frame = commentBgPosition;
            commentBgStorage.contents = [UIImage imageNamed:@"comment"];
            [commentBgStorage stretchableImageWithLeftCapWidth:40 topCapHeight:15];
        }
        /**************************将要在同一个LWAsyncDisplayView上显示的Storage要全部放入同一个LWLayout中***************************************/
        /**************************我们将尽量通过合并绘制的方式将所有在同一个View显示的内容全都异步绘制在同一个AsyncDisplayView上**************************/
        /**************************这样的做法能最大限度的节省系统的开销**************************/
        [self addStorage:nameTextStorage];
        [self addStorage:contentTextStorage];
        [self addStorage:dateTextStorage];
        [self addStorages:commentTextStorages];
        [self addStorage:avatarStorage];
        [self addStorage:commentBgStorage];
        [self addStorage:likeImageSotrage];
        [self addStorages:imageStorageArray];
        if (likeTextStorage) {
            [self addStorage:likeTextStorage];
        }
        //一些其他属性
        self.menuPosition = menuPosition;
        self.commentBgPosition = commentBgPosition;
        self.imagePostionArray = imagePositionArray;
        self.statusModel = statusModel;
        //如果是使用在UITableViewCell上面，可以通过以下方法快速的得到Cell的高度
        self.cellHeight = [self suggestHeightWithBottomMargin:15.0f];
        /********************* 有任何问题欢迎反馈给我 liuweiself@126.com ****************************************/
        /***************  https://github.com/waynezxcv/Gallop 持续更新完善，如果觉得有帮助，给个Star~[]***************************/
        /******************** 正在不断完善中，谢谢~  Enjoy ******************************************************/
    }
    return self;
}

@end
