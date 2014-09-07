//
//  main.cpp
//  GameOfLife
//
//  Created by Zach Evans on 11/18/12.
//  Copyright (c) 2012 Zach Evans. All rights reserved.
//

#include <iostream>
#include <iomanip>
#include <fstream>


using namespace std;


int worldHeight; //Height of the grid (constant throughout program)
int worldWidth; //Width of the grid (constant throughout program)
int offsetX; // X-Coordinate of top-left corner of pattern
int offsetY; // Y-Coordinate of top-left corner of pattern
int activeWorld = 1; //Active grid (switches between generations)


void clearBorders(int** arrayOne, int** arrayTwo){
    for (int i = 0; i < worldWidth+2; i++){
        arrayOne[0][i] = 0;
        arrayOne[worldHeight+1][i] = 0;
        arrayTwo[0][i] = 0;
        arrayTwo[worldHeight+1][i] = 0;
    }
    for (int i = 0; i < worldHeight+2; i++){
        arrayOne[i][0] = 0;
        arrayOne[i][worldWidth + 1] = 0;
        arrayTwo[i][0] = 0;
        arrayTwo[i][worldWidth + 1] = 0;
    }
}



// Prints an array given the array, number of rows, and number of columns
void printArray(int** inArray, int numRows, int numCols){
    cout << " ";
    for (int i = 0; i < numCols * 2; i++){
        cout << "-";
    }
    cout << endl;
    for(int i = 1; i <= numRows; i++){
        cout << "|";
        for (int j = 1; j <= numCols; j++){
            if (inArray[i][j] == 0){
                cout << " ";
            }
            else if (inArray[i][j] == 1){
                cout << "*";
            }
            cout << " ";
           
        }
        cout << "|" << endl;
    }
    cout << " ";
    for (int i = 0; i < numCols * 2; i++){
        cout << "-";
    }
    cout << endl;
    
}


// Takes in array and coordinates of cell.
// Returns true if cell should be alive and false if cell should die
bool arrayCheck(int** inArray, int arrayRow, int arrayCol){
    
    int adjAlive = 0; //Alive adjacent spaces
    int currentState = inArray[arrayRow][arrayCol];
    
    if (inArray[arrayRow-1][arrayCol-1] == 1){
        adjAlive++;
    }
    
    if (inArray[arrayRow][arrayCol-1] == 1){
        adjAlive++;
    }
    
    if (inArray[arrayRow+1][arrayCol-1] == 1){
        adjAlive++;
    }
    if (inArray[arrayRow-1][arrayCol] == 1){
        adjAlive++;
    }
    if (inArray[arrayRow + 1][arrayCol] == 1){
        adjAlive++;
    }
    if (inArray[arrayRow-1][arrayCol+1] == 1){
        adjAlive++;
    }
    if (inArray[arrayRow][arrayCol+1] == 1){
        adjAlive++;
    }
    if (inArray[arrayRow+1][arrayCol+1] == 1){
        adjAlive++;
    }
    
    if ((currentState == 1) && (adjAlive == 2 || adjAlive == 3)){
        return true;
    }
    else if ((currentState == 1) && (adjAlive < 2 || adjAlive > 3)){
        return false;
    }
    else if ((currentState == 0) && adjAlive == 3){
        return true;
    }
    else if ((currentState == 0) && adjAlive != 3){
        return false;
    }
    else {
        cout << "This should never happen.";
        return false;
    }
    
}


// Given two arrays and their dimensions, creates next generation of first array on the other.
void nextGeneration(int** fromArray, int** toArray, int numRows, int numCols){ //Create next generation in toArray
    
    for (int i = 1; i <= numRows; i++){
        for (int j = 1; j <= numCols; j++){
            if (arrayCheck(fromArray, i, j)){
                toArray[i][j] = 1;
            }
            else{
                toArray[i][j] = 0;
            }
            
        }
    }
    
    clearBorders(fromArray, toArray);
    
    
    if (activeWorld == 1){
        activeWorld = 2;
    }
    
    else if (activeWorld == 2){
        activeWorld = 1;
    }
    
    printArray(toArray, numRows, numCols);
}


// Calls nextGeneration correctly based on current active world
void callNextGeneration(int** firstWorld, int** secondWorld){
    if (activeWorld == 1){
        nextGeneration(firstWorld, secondWorld, worldHeight, worldWidth);
    }
    else if (activeWorld == 2){
        nextGeneration(secondWorld, firstWorld, worldHeight, worldWidth);
    }
}

int main(int argc, const char * argv[])
{
    
    
    string fileName; //Name of the pattern file
    ifstream in_file; //Input filestream for pattern file
    
    cout << "Enter the file name for your pattern: ";
    cin >> fileName;
    
    in_file.open(fileName.c_str());
    
    if (in_file.fail()){ //Checks for invalid file
        cout << "Invalid data file";
        return 1;
    }
    
    in_file >> worldWidth;
    in_file >> worldHeight;
    in_file >> offsetX;
    in_file >> offsetY;
    
   
    int** worldOne = new int*[worldHeight + 2]; // Declaring the two arrays 
    int** worldTwo = new int*[worldHeight + 2];
    

    
    
    for (int i = 0; i < worldHeight + 2; i++){ // Making the arrays two-dimensional
        
        worldOne[i] = new int[worldWidth + 2];
        worldTwo[i] = new int[worldWidth + 2];
        
    }
    
    for (int i = 0; i < worldHeight + 2; i++){ // Initializing everything to 0
        for (int j = 0; j < worldWidth + 2; j++){
            worldOne[i][j] = 0;
            worldTwo[i][j] = 0;
        }
    }
    //Changing offsets to account for the border
    offsetY++;
    offsetX++;
    
    
    //Building the array from the input file
    
    string lineString;
    int startLine = offsetX - 1;
    
    while(in_file.good()){
        
        getline(in_file, lineString);
        for (int i = 0; i < lineString.length(); i++){
            if (lineString[i] == ' '){
                worldOne[startLine][i + offsetY] = 0;
                worldTwo[startLine][i + offsetY] = 0;
            }
            else if(lineString[i] == '*'){
                worldOne[startLine][i + offsetY] = 1;
                worldTwo[startLine][i + offsetY] = 1;
            }
            
        }
        startLine++;
        
    }
    
    // Print the array as given in the file to show the grid before any activity
    printArray(worldOne, worldHeight, worldWidth);
    
    // Asking for number of generations
    int numGenerations;
    cout << "How many generations to being with? ";
    cin >> numGenerations;
    
    
    for (int i = 0; i < numGenerations; i++){
        callNextGeneration(worldOne, worldTwo);
        cout << endl;
    }
    
    
    while (true){ // Loop until no more generations are requested
        cout << "How many more generations? ";
        cin >> numGenerations;
        
        if (numGenerations >= 1){
            for (int i = 0; i < numGenerations; i++){
                callNextGeneration(worldOne, worldTwo);
                cout << endl;
            }
        }
        else if (numGenerations < 1){
            break; //Leave the loop if no more generations requested
        }
        
    }
    
    in_file.close(); // Close the pattern file
    return 0;
}

