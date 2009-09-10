@import <AppKit/AppKit.j>
@import "ConstantsPMR.j"

@implementation DragListPMR : CPPanel
{
  CPDragType dragType;
  CPCollectionView collectionView;
}


- (id) initWithContentRect: panelRect
{
  self = [self initWithContentRect: panelRect
                         styleMask: CPHUDBackgroundWindowMask | CPResizableWindowMask];
  [self setFloatingPanel:YES];
  return self;
}

- (id)addCollectionViewSupplying: someDragType signalingWith: color 
{
  dragType = someDragType;
  
  var bounds = [self usableArea];
  collectionView = [self placeCollectionViewAt: bounds];
        
  [collectionView setDelegate:self]; // TODO get rid of this? or point to controller?
  [self describeItemsTo: collectionView];
  [self surround: collectionView withScrollViewColored: color];

  return self;
}


- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  var element = [[aCollectionView content] objectAtIndex:[indices firstIndex]];
  return [CPKeyedArchiver archivedDataWithRootObject:element];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [dragType];
}


// CollectionView protocol implemented 
- (void) setContent: content
{
  [collectionView setContent: content];
}

// View protocol implemented
- (void) setNeedsDisplay: value
{
  [[self contentView] setNeedsDisplay: value];
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
    var collectionView = [[CPCollectionView alloc] initWithFrame:rect];
        
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
  [self setStringValue: anObject];
}

@end