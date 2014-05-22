//
//  Maze.m
//  Bartender
//
//  Created by Tom Houpt on 09/7/12.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//	
//	based on pseudocode at:
//	http://www.mazeworks.com/mazegen/mazetut/index.htm
//

#import "Maze.h"

@implementation CellMaze


-(id)initAtX:(int)x_coord andY:(int)y_coord ofWidth:(int)width
	
	// cell 0,0 is in NorthWest corner
	// cell width-1,width-1 is in SouthEast corner
	
	self = [super init];
	
	x = x_coord; y = y_coord;
	
	int side;
	for (side = NORTH; side <= WEST; side++) {
		wall[side] = YES;
		border[side] = NO;
		neighbor[side] = nil;
	}
	
	if (y == 0) border[NORTH] = YES;
	if (y == width-1) border[SOUTH] = YES;
	if (x == 0) border[EAST] = YES;
	if (x == width-1) border[WEST] = YES;

}

-(BOOL)allWallsIntact {
	
	for (side = NORTH; side<=WEST; side++) {
		
		//don't count border sides
		if (!border[side] && !wall[side]) return NO;
		
	}
	return YES;
	
}

-(void)knockWallDownOnSide:(int)side {
	wall[side] = NO;
}
-(MazeCell *)neighborOnSide:(int)side {
	
	return neighbor[side];
	
}
-(void)setNeighborOnSide:(int)side toCell:(MazeCell *)theCell;


@end

//*****************************************************************
//*****************************************************************

@implementation Maze


-(id)init ofWidth:(int)width {
	


// set TotalCells = number of cells in grid
	
	int totalCells = width * width;
	
	
// make an array of cells to hold the cells
	
	MazeCell *theCell;
	;
	cells = [[NSMutableArray  alloc] init];
	
	// allocate the all the cells
	for (xIndex =0; xIndex < width; xIndex++) {
		for (yIndex =0; yIndex < width; yIndex++) {
			theCell = [[MazeCell alloc] initAtX:xIndex andY:yIndex ofWidth:width];
			[cells addObject:theCell];
		}
	}

	for (xIndex =0; xIndex < width; xIndex++) {
		for (yIndex =0; yIndex < width; yIndex++) {

			theCell = [cells objectAtIndex: ((width * x) + y)];
		
			northCell = [cells objectAtIndex: ((width * x) + y-1)];
			eastCell = [cells objectAtIndex: ((width * x+1) + y)];
			southCell = [cells objectAtIndex: ((width * x) + y+1)];
			westCell = [cells objectAtIndex: ((width * x-1) + y)];

			[theCell setNeighborOnSide:NORTH toCell:northCell];
			[theCell setNeighborOnSide:EAST toCell:eastCell];
			[theCell setNeighborOnSide:SOUTH toCell:southCell];
			[theCell setNeighborOnSide:WEST toCell:westCell];			
			
		}
	}
	
	
	
		
	
// create a CellStack (LIFO) to hold a list of cell locations  
	
	CellLocationStack *locationStack = [CellLocationStack totalCells];
	
// choose a cell at random and call it CurrentCell  
	
	currentCell = [cells objectAtIndex:(rnd(totalCells))];
	
// set VisitedCells = 1  
	
	int visitedCells = 1;

// while VisitedCells < TotalCells 
	
	while (visitedCells < totalCells) {
		
		// find all neighbors of CurrentCell with all walls intact 
		for(side = NORTH; side < WEST; side++)
			if ([[currentCell neighborOnSide:side] allWallsIntact])
					[intactNeighbors addObject: 
		// if one or more found
		
		// choose one at random  
		
		// knock down the wall between it and CurrentCell  
// push CurrentCell location on the CellStack  
// make the new cell CurrentCell  
// add 1 to VisitedCells
// else 
// pop the most recent cell entry off the CellStack  
// make it CurrentCell
// endIf
// endWhile  
	
}





@end
