 /* CS 352 -- Expand Function
 * $Id: expand.c,v 1.30 2014/06/06 05:44:43 evansz2 Exp $
 *  Zach Evans
 *  CSCI 352
 *  Spring 2014
 */

#include "proto.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <ctype.h>
#include <strings.h>
#include <math.h>
#include <limits.h>
#include <dirent.h>
#include <pwd.h>
#include <signal.h>

int contextMatch(char *contextString, char *matchString){
	
	int contextLength = strlen(contextString);
	int matchLength = strlen(matchString);
	
	int i;
	if (matchLength < contextLength || contextLength == 0){
		return 0;
	}
	for (i = 0; i < contextLength; i++){
		
		if (contextString[i] != matchString[matchLength-contextLength+i]){
			return 0;
		}
	}
	return 1;
}

int replWithContextFiles(char *contextStart,char *replBuf, int *currentSize, int maxSize, int *contextLength){
	/*
	contextStart: beginning of the context
	replBuf: The new buffer in which the replaced filenames are placed
	currentSize: Pointer to the variable holding the current size of the buffer
	maxSize: maximum size of the buffer
	contextLength: returns the length of the context for the walking pointer to use
	*/
	char contextBuffer[LINELEN];
	int ctxBufIdx = 0; //Context buffer index
	DIR *workingDir = opendir(".");
	struct dirent *currentDir;
	int nameLen;
	int first = 1;
	int replCount = 0;
	char *walk;
	int ctxLen;
	for (walk = contextStart +1;*walk != ' ' && *walk !='"' && *walk !=0;walk++){
		strncpy(&contextBuffer[ctxBufIdx], walk, 1);
		ctxBufIdx++;
	}
	contextBuffer[ctxBufIdx] = '\0';
	ctxLen = strlen(contextBuffer);
	*contextLength = ctxLen;
	
	while((currentDir = readdir(workingDir)) != NULL){
		if (currentDir->d_name[0] != '.' && contextMatch(contextBuffer, currentDir->d_name)){
			nameLen = strlen(currentDir->d_name);
			if (nameLen <= maxSize-(*currentSize)){	
				if (first == 1){
					first = 0;
				}
				else{
					strncpy(&replBuf[*currentSize], " ", 1);
					*currentSize += 1;
				}
				strncpy(&replBuf[*currentSize], currentDir->d_name, nameLen);
				*currentSize += nameLen;
				replCount ++;
				
			}
			else{
				return -1;
			}	
			
		}
	}
	if (replCount == 0){ //Keep the pattern in the buffer
		ctxLen++;
		strncpy(&replBuf[*currentSize], contextStart, ctxLen);
		*currentSize += ctxLen;
	}
	
	return 0;
}

int replWithAllFiles(char *replBuf, int *currentSize, int maxSize){
	/*
	replBuf: buffer to place in the new files
	currentSize: pointer to the variable holding the current size of the new buffer
	maxSize: max size of the new buffer
	*/
	DIR *workingDir = opendir(".");
	struct dirent *currentDir;
	int nameLen;
	int first = 1;
	while((currentDir = readdir(workingDir)) != NULL){
		if(currentDir->d_name[0] != '.'){
			nameLen = strlen(currentDir->d_name);
			if (nameLen <= maxSize-(*currentSize)){	
				if (first == 1){
					first = 0;
				}
				else{
					strncpy(&replBuf[*currentSize], " ", 1);
					*currentSize += 1;
				}
				strncpy(&replBuf[*currentSize], currentDir->d_name, nameLen);
				*currentSize += nameLen;
				
			}
			else{
				return -1;
			}	
		}	
	}
	return 0;
}


int replWalkInt(char *replBuf, int replInt, int *newLen, int maxSize){
  /*
  replBuf: Buffer to place replacement
  replInt: The int to replace with its ascii value
  newLen: pointer to the size index of the new buffer
  maxSize: max size of the new buffer
  */
  int intSize = floor(log10(INT_MAX)+1);
  char digitBuf[intSize];
  int intLen = snprintf(digitBuf, intSize+1, "%i", replInt);
  if (intLen < maxSize-(*newLen)){
    strncpy(&replBuf[*newLen], digitBuf, intSize);
    *newLen += intLen;
    replBuf[*newLen] = ' ';
    return 0;
  }
  else{
    return -1;
  }
}
int replWalkPid(char *replBuf, pid_t replpid, int *newLen, int maxSize){
  /*
  replBuf: Buffer to place replacement
  replInt: The int to replace with its ascii value
  newLen: pointer to the size index of the new buffer
  maxSize: max size of the new buffer
  */
	
  int intSize = 10;
  char digitBuf[intSize];
  int intLen = snprintf(digitBuf, intSize+1, "%i", replpid);
  if (intLen < maxSize-(*newLen)){
    strncpy(&replBuf[*newLen], digitBuf, intSize);
    *newLen += intLen;
    replBuf[*newLen] = ' ';
    return 0;
  }
  else{
    return -1;
  }
}

int replProgramOutput(char *newBuf, int *newLen,char *origOpenParen, char *origCloseParen, int maxSize){
	
	/*
	Name: replProgramOutput
	Input: 
		newBuf: the buffer where the program output is being placed
		newLen: Pointer to the integer keeping track of the length of newBuf
		origOpenParen: Pointer to the original open parenthesis in the command
		origCloseParen: Pointer to the original close parenthesis in the command
		maxSize: The maximum size of newBuf
	
	Output:
		Returns 0 if successful, -1 otherwise with an error message printed
	*/
	
	int programPipe[2];
	char outputDataBuffer[LINELEN];
	int bufLen = 0;
	int readLen;
	int valid = 1;
	if (pipe(programPipe)<0){
		dprintf(2,"Couldn't create pipe");
		return -1;
	}
	*origCloseParen = 0;
	int processResult = processline(origOpenParen+1, 0, programPipe[1], 2);
	if (processResult < 0){ //Error
		dprintf(2,"Error processing line\n");
		return -1;
	}
	else{ //No error, might be a child
		close(programPipe[1]);
		while((readLen = read(programPipe[0], &outputDataBuffer[bufLen], LINELEN-bufLen)) > 0 && bufLen < LINELEN){
			bufLen += readLen;	
			if (bufLen == LINELEN){
				break;
			}
		}
		if (readLen != 0){
			valid = 0;
			if (processResult > 0){
				kill(processResult, SIGINT);
			}
		}
		close(programPipe[0]);	
		int outputWalk;
		if (valid){
			if (outputDataBuffer[bufLen-1] == '\n'){ //Replace final \n with null-terminator
				bufLen--;
			}
			for (outputWalk = 0;outputWalk < bufLen; outputWalk++){
				if (outputDataBuffer[outputWalk] == '\n'){
					outputDataBuffer[outputWalk] = ' ';
				}
			}
		}
		if (processResult > 0){ //Child to wait on
			int waitStatus;
			waitingCPID = processResult; //For the SIGINT handler
			if (waitpid(processResult, &waitStatus, 0) < 0){
				perror("wait");
			}
			waitingCPID = 0; //No longer waiting on a child
			if (WIFEXITED(waitStatus)){
				lastExit = WEXITSTATUS(waitStatus);
			}
			else{
				lastExit = 127;
			}
		}
		if (bufLen > maxSize-*newLen || !valid){
			dprintf(2, "Expanded string too long\n");
			return -1;
		}
		strncpy(&newBuf[*newLen], outputDataBuffer, bufLen);
		*newLen += bufLen;
		*origCloseParen = ')';
	}
	return 0;
}

int parseInt(char *start, char **finish){
  char digitBuf[LINELEN];
  int i = 0;
  char c;
  bzero(digitBuf, LINELEN);
  while(isdigit(c = *start++)){
    digitBuf[i++] = c;
  }
  *finish = --start;
  return atoi(digitBuf);
}

char *findEndChar(char *start, char endChar, int *len){
  /*
  start: pointer to the character to start the search from
  endChar: The character you're looking for
  len: Pointer to an integer to fill with the length of the argument

  Returns pointer to the character you're attempting to find or NULL if never found
  */
  char c;
  int dist = 0;
  char *walk = start;
  while ((c = *walk)!=0){
    if(c == endChar){
      *len = dist;
      return walk;
    }
    dist++;
    walk++;
  }
  return NULL;
}

char *findEndParen(char *start, int *len){
	/*
	start: pointer to the opening paren
	len: pointer to int to fill with the length of the enclosed content
	
	returns pointer to the closing paren, NULL if none found
	*/
	
	int parenCount = 0;
	int dist = 0;
	char c;
	char *walk = start;
	while ((c = *walk) != 0){
		if (c == '('){
			parenCount++;
		}
		else if (c == ')'){
			parenCount--;
		}
		if (parenCount == 0){
			*len = dist-1;
			return walk;
		}
		dist++;
		walk++;
	}
	return NULL;
	
}

char *findReplaceEnv(char *replStart, int argLen){
  /*
  replStart: points to $ in "${HOME}"
  argLen: ${HOME} would have argLen of 4

  Returns string pointing to the proper environment variable string.
  */

  char getEnvBuf[LINELEN]; //Buffer for input to getenv()
  strncpy(getEnvBuf, replStart+2, argLen); //Copy over just the name of the argument
  getEnvBuf[argLen] = 0; //add null terminator
  char *envString;
  if ((envString = getenv(getEnvBuf))!=NULL){
    return envString;
  }
  else{
    return "";
  }

}



char findNextChar(char *start){
  /*
  start: Pointer to the starting character

  Returns character after start
  */
  return(*(start+1));
}

int expand (char *orig, char *new, int newsize){
  /*
  orig: Original buffer (variables to be replaced)
  new: New buffer (variables have been replaced)
  newsize: Size of the new buffer to avoid overflow
  */
  int origLen = strlen(orig); //Length of the original buffer
  int newLen = 0; //Length of the new buffer(updated with writes)
  char *replEnd; //Pointer to the end of a replacement
  int replLen; //Length of the text to be replaced
  char c; //Character for parsing string
  char *walk = orig; //Walking pointer for original buffer
  int inQuote = 0;

  while ((c = *walk)!=0 && walk-orig < origLen && newLen < newsize && !hadSigInt){
    if (c == '$'){
      char next = findNextChar(walk); //Next character in the buffer

      if(next == '$'){ //Found $$, pid expansion
        replWalkPid(new, getpid(), &newLen, LINELEN);
		walk += 2;
    
      }
	  else if (next == '('){ //found $(, command expansion
		  replEnd = findEndParen(walk+1, &replLen);
		  if (replEnd == NULL){
			  dprintf(2, "No matching ) found\n");
			  return -1;
		  }
		  if (replProgramOutput(new, &newLen, walk+1, replEnd, newsize) < 0){
				return -1;
			}
			else{
				walk = replEnd+1;
			}
	  }
      else if(next =='{'){ //found ${, environment variable expansion
        replEnd = findEndChar(walk+2, '}', &replLen); //Start the search on H of "${HOME}", will fill replLen with 0 if given "${}"
        if (replEnd == NULL){
          dprintf(2, "Missing end brace for environment variable\n");
          return -1;
        }
        else{
          char *envReplace = findReplaceEnv(walk, replLen); //String that replaces variable
          int envLen = strlen(envReplace); //Length of the new text
          if (newsize-newLen >= envLen){
            strncpy(&new[newLen], envReplace, envLen); //Copy over the new text
            newLen+= envLen; //Increase the length of the new line by the size of the new text
            walk = replEnd+1; //Move the walking pointer to the end of the variable text
          }
          else{
            dprintf(2, "Expanded string too long\n");
            return -1;
          }
        }
      }
      else if(isdigit(next)){ //Found argv replacement
        int argNum = parseInt(walk+1, &walk); //Moves walk past the int
		if (argNum == 0 && interactive){
			strncpy(&new[newLen], mainargv[0], strlen(mainargv[0]));
			newLen += strlen(mainargv[0]);
		}
		else{
	        argNum += shiftIndex;
	        if (argNum < mainargc - 1){
	          int newArgLen = strlen(mainargv[argNum+1]);
	          strncpy(&new[newLen], mainargv[argNum+1], newArgLen); //Copy in argument
	          newLen += newArgLen;
	        }
		}
      }
      else if(next == '#'){ //Show number of available arguments
		  if (interactive){
			  replWalkInt(new, 1, &newLen, LINELEN); //Interactive always shows 1
		  }
		  else{
			  replWalkInt(new, mainargc-1-shiftIndex, &newLen, LINELEN); //Replace with $#
		  }
        walk += 2;
      }
      else if(next == '?'){ //Show last exit value
		replWalkInt(new, lastExit, &newLen, LINELEN);
        walk += 2;

      
      }
      else{ //Not a special $
        strncpy(&new[newLen], walk, 1); //Copy over $
        newLen++;
        walk++;
      }
    }
	else if (c == '*'){
		if ((*(walk+1) == ' ' ||*(walk+1) == '\0') && walk-orig >= 1 && (*(walk-1)== ' '  || *(walk-1) == '"')){
			if(replWithAllFiles(new, &newLen, newsize) < 0){ //Replace with all filenames
				dprintf(2, "Expanded string too long\n");
				return -1;
			}
		}
		else if(*(walk+1) != ' ' && *(walk+1) != '\0' && walk-orig >= 1){
			int contextLength;
			
			replWithContextFiles(walk, new, &newLen, newsize, &contextLength); //Replace with file names matching context
			walk += contextLength;
		} 	
		else{
	        strncpy(&new[newLen], walk, 1); //Copy over *
	        newLen++;
		}
		walk++;
	}
	else if (c == '"'){ //Finding quotes
		
		inQuote = !inQuote;
        strncpy(&new[newLen], walk, 1); //Copy over one character
        newLen++;
		walk++;
       
	}
	else if (c == '~'){ //Home directory expansion
		if ((walk-orig == 0 || *(walk-1) == ' ')){
			if((*(walk+1) == ' ' || *(walk+1) == '/' || *(walk+1) == 0)){ //Before 
				struct passwd *userInfo = getpwuid(getuid());
				int dirLen = strlen(userInfo->pw_dir);
				strncpy(&new[newLen], userInfo->pw_dir, dirLen);
				newLen += dirLen;
				walk++;
			}
			else{
				
				int spaceCount = 0;
				char *spaceWalk = walk;
				char nameBuffer[32];
				for(;*++spaceWalk != ' ' && *spaceWalk != 0 && *spaceWalk != '/';spaceCount++); //Move spaceWalk to next space
				strncpy(nameBuffer, walk+1, spaceCount); //Copy name into buffer
				nameBuffer[spaceCount] = 0; //Add null terminator
				struct passwd *userInfo = getpwnam(nameBuffer);//Get home directory
				if (userInfo != NULL){
					int dirLen = strlen(userInfo->pw_dir);
					strncpy(&new[newLen], userInfo -> pw_dir, dirLen); //Copy in name
					newLen += dirLen;
					walk+=1+strlen(nameBuffer);
				}
				else{
					strncpy(&new[newLen], walk, spaceCount+1);
					newLen += spaceCount;
					walk = spaceWalk - 1;
				}
				
			}
	
		}
		else{
			strncpy(&new[newLen], walk, 1);
			newLen++;
			walk++;
		}		
	}
	else if (c == '\\'){
		if (*(walk+1) == '*'){
	        strncpy(&new[newLen], walk+1, 1); 
	        newLen++;
	        walk+=2;
		}
		else{
	        strncpy(&new[newLen], walk, 1); //Copy over one character
	        newLen++;
	        walk++;
		}
	}
    else{ //Not a special character
      strncpy(&new[newLen], walk, 1); //Copy over one character
      newLen++;
      walk++;
    }
  }
  if (hadSigInt){
	  hadSigInt = 0;
	  return -1;
  }
  new[newLen] = 0;
  return 1;
}
