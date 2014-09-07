#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <unistd.h>
#include "proto.h"
#include "fcntl.h"

#define FMODE 0666

typedef enum{R_STDIN, R_OUT, R_OUTAPP, R_ERR, R_ERRAPP} redirect_t;

char* findRedirectChar(char* line){
	int inQuote = 0;
	int i;
	int lineLen = strlen(line);
	char c;
	for (i = 0; i < lineLen; i++){
		c = line[i];
		if(c== '"'){
			inQuote = !inQuote;
		}
		else if(!inQuote && (c =='<' || c == '>')){
			return &line[i];
		}
	}
	return NULL;
}





int findRedirections(char *line, int *infd, int *outfd, int *errfd){
	/*
	Name: findRedirections
	Input:
		line: The working line
		infd: pointer to an input file descriptor
		outfd: pointer to an output file descriptor
		errfd: pointer to an error file descriptor
	Output:
		0 if successful, -1 if error with message printed
	Purpose:
		To parse a string for redirection operators and deal with file IO
	*/
	
	char *redirectStart = line; //First '<' or '>' in the redirect (changed by findRedirectChar())
	char fileBuf[256]; //buffer to hold the name of the line
	int bufLen;
	
	redirect_t redirType;
	
	
	while ((redirectStart = findRedirectChar(redirectStart)) != NULL){ //While there are redirect characters
		
		
		//Find out what kind of redirect
		if (*redirectStart == '>'){  //stderr or stdout
			if (*(redirectStart+1) != '\0' && *(redirectStart+1) == '>'){ //Append
				if (redirectStart-line >= 1 && *(redirectStart -1) == '2' && 
					 (redirectStart-line == 2 || (redirectStart-line > 2 && *(redirectStart - 2) == ' '))){ //Append stderr
					 redirType = R_ERRAPP; // 2>>
					 *(redirectStart - 1) = ' '; //Set 2 to space
					
				}
				else if(redirectStart-line >= 1 && *(redirectStart -1) !='2'){ //Append stdout
					redirType = R_OUTAPP; // >>
				}
				*(redirectStart+1) = ' '; // Set second bracket to space
			}
			else{ //No append
				if (redirectStart-line >= 1 && *(redirectStart -1) == '2' && 
					(redirectStart-line == 2 || (redirectStart-line > 2 && *(redirectStart - 2) == ' '))) //Create stderr
					{
						redirType = R_ERR; // 2>
						*(redirectStart - 1) = ' '; // Set 2 to space
					}
				else if(redirectStart-line >= 1 && *(redirectStart -1)!='2'){ //Create stdout
					redirType = R_OUT; // >
				}
			}
		}
		else if(*redirectStart == '<'){//stdin
			redirType = R_STDIN; // <
		}
		*redirectStart = ' ';//Set original redirect bracket to space
		for (;*redirectStart == ' '; redirectStart++); //Skip spaces
		bufLen = 0;
		for (;*redirectStart != ' ' && *redirectStart != '\0' && *redirectStart != '<' && *redirectStart != '>' && bufLen < 256; redirectStart++){ //Copy file name
			strncpy(&fileBuf[bufLen++], redirectStart, 1);
			*redirectStart = ' '; //Change the file name to spaces
		}
		if (bufLen == 256){ //File name too long for UNIX machine
			dprintf(*errfd, "File name too long\n");
			return -1;
		}
		fileBuf[bufLen] = '\0'; //Add null-terminator
		if (bufLen == 0){//No filename
			dprintf(*errfd, "No filename given for redirect operator\n");
			return -1;
		}
		
		switch (redirType){
			case R_STDIN:
				*infd = open(fileBuf, O_RDONLY);
				break;
			
			case R_OUT:
				*outfd = open(fileBuf, O_WRONLY|O_CREAT|O_TRUNC, FMODE);
				break;
			
			case R_OUTAPP:
				*outfd = open(fileBuf, O_WRONLY|O_CREAT|O_APPEND, FMODE);
				break;
			
			case R_ERR:
				*errfd = open(fileBuf, O_WRONLY|O_CREAT|O_TRUNC, FMODE);
				break;
				
			case R_ERRAPP:
				*errfd = open(fileBuf, O_WRONLY|O_CREAT|O_APPEND, FMODE);
				break;
		}
	}
	return 0;
}



