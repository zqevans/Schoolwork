#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

using namespace std;

int string_to_int(string s)
 {
        istringstream instr(s);
        int n;
        instr >> n;
        return n;
 }



int main(int argc, const char * argv[])
{
    fstream fileOne;
    fstream fileTwo;
    string fileOneName;
    string fileTwoName;
    string fileOneLine;
    string fileTwoLine;
    int numDifs;
    int difCount = 0;
    bool allDifs = false;
    
    
    
    for (int i = 1; i < argc; i++)
    {
        cout << argv[i] << "\n";
        
    }
    
    if (argc >= 1)
    {
        string arg = string(argv[1]);
        if (arg.length() >= 2 && arg[0] == '-')
        {
            if (arg[1] == 'a')
            {
                allDifs = true;
            }
            else
            {
                numDifs = string_to_int(arg.substr(1, arg.length() - 1));
            }
        }
        
        if (argc >= 3) //Assuming three arguments: the flag, and two file names
        {
            fileOneName = string(argv[2]);
            fileTwoName = string(argv[3]);
        }   
    
    }
    
    if (argc == 2) //Only argument is the flag
    {
    cout << "Please enter file one: ";
    cin >> fileOneName;
    
    cout << "Please enter file two: ";
    cin >> fileTwoName;
    }
    
    fileOne.open(fileOneName.c_str());
    fileTwo.open(fileTwoName.c_str());
    
    if (fileOne.fail())
    {
        cout << "Unable to open" << fileOneName << "\n";
    }
    
    if (fileTwo.fail())
    {
        cout << "Unable to open" << fileTwoName << "\n";
    }
    


    
    int lineNumber = 1;
    while (!fileOne.fail() && !fileTwo.fail())
    {

        getline(fileOne, fileOneLine);
        getline(fileTwo, fileTwoLine);
        
        if (fileOne.fail() && !fileTwo.fail())
        {
            cout << "File 1 is shorter.\n";
            break;
        }
        
        if (fileTwo.fail() && !fileOne.fail())
        {
            cout << "File 2 is shorter.\n";
            break;
        }
        
        if (fileOne.fail() && fileTwo.fail())
        {
            cout << "Files are identical.\n";
        }
        
        if (fileOneLine != fileTwoLine && difCount < numDifs)
        {
            cout << "Line number: " << lineNumber << "\n";
            cout << "File 1: " << fileOneLine << "\n";
            cout << "File 2: " << fileTwoLine << "\n";
            if (!allDifs)
            {
                difCount++;
            }
        }
        lineNumber++;
    }
    

    

    return 0;
}

