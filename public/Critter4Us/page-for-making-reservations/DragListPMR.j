@import <AppKit/AppKit.j>
@import "ConstantsPMR.j"
// @import "../view/SummaryShowingCollectionViewItem.j"
@import "../view/DebuggableCollectionView.j"

@implementation DragListPMR : CPPanel
{
  CPDragType dragType;
}


- (id) initWithContentRect: panelRect
{
  self = [self initWithContentRect: panelRect
                         styleMask: CPHUDBackgroundWindowMask | CPResizableWindowMask];
  [self setFloatingPanel:YES];
  return self;
}

- (CPCollectionView)addCollectionViewSupplying: someDragType signalingWith: color 
{
  dragType = someDragType;
  
  var bounds = [self usableArea];
  var collectionView = [self placeCollectionViewAt: bounds];
        
  [self describeItemsTo: collectionView];
  [self surround: collectionView withScrollViewColored: color];

  return collectionView;
}

// Util

- (CPRect) usableArea
{
  var contentView = [self contentView];
  var bounds = [contentView bounds];
  bounds.size.height -= WindowBottomMargin;
  return bounds;
}

- (CPCollectionView) placeCollectionViewAt: rect
{
    var collectionView = [[DebuggableCollectionView alloc] initWithFrame:rect];
        
    [collectionView setAutoresizingMask:CPViewWidthSizable];
    return collectionView;
}

- (void) describeItemsTo: (CPCollectionView) collectionView
{
  var itemPrototype = [[CPCollectionViewItem alloc] init];
  [itemPrototype setView:[[DragListItemViewPMR alloc] initWithFrame:CGRectMakeZero()]];
  [collectionView setItemPrototype:itemPrototype];
  [collectionView setMinItemSize:CGSizeMake(CompleteTextLineWidth, TextLineHeight)];
  [collectionView setMaxItemSize:CGSizeMake(CompleteTextLineWidth, TextLineHeight)];
}



- (void) surround: collectionView withScrollViewColored: color
{
    var scrollView = [[CPScrollView alloc] initWithFrame: [collectionView bounds]];
        
    [scrollView setDocumentView:collectionView];
    [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setAutohidesScrollers:YES];

    [[scrollView contentView] setBackgroundColor:color];

    [[self contentView] addSubview:scrollView];
}

@end

@implementation DragListItemViewPMR : CPTextField
{
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

- (void)setRepresentedObject:(id)anObject
{
  if ([anObject respondsToSelector: @selector(summary)]) // TODO temp during migration from strings to objects.
  {
    [self setStringValue: [anObject summary]];
  }
  else
  {
    [self setStringValue: anObject];
  }
}

@end

