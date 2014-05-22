//
//  Maze.h
//  Bartender
//
//  Created by Tom Houpt on 09/7/12.
//  Copyright 2009 Behavioral Cybernetics. All rights reserved.
//
//	
//	based on pseudocode at:
//	http://www.mazeworks.com/mazegen/mazetut/index.htm
//

#import <Cocoa/Cocoa.h>

enum side = {NORTH = 0,EAST,SOUTH,WEST };

@interface MazeCell : NSObject {
		
	int x,y; // x,y position of this cell
	
	BOOL wall[4]; // yes, if side is intact
	BOOL border[4]; // yes, if side is a border
		
	BOOL visited;
		// whether the cell was visited during generation of the maze
	
	MazeCells neighbor[4];
}

-(id)initAtX:(int)x_coord andY:(int)y_coord ofWidth:(int)width

-(BOOL)allWallsIntact;
-(BOOL)knockWallDownOnSide:(int)side;
-(MazeCell *)neighborOnSide:(int)side;
-(void)setNeighborOnSide:(int)side toCell:(MazeCell *)theCell;

@end

@interface CellLocation: NSObject {
	
	
	
}

@end

@interface Maze : NSObject {
	
	int width; // width of the array of cells
	
	int totalCells; // total number of cells, set to width * width
	
	NSMutableArray cells;
	

}

@end
