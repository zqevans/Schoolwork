/* CS 352 -- Mini Shell!
 *  $Id: msh.c,v 1.23 2014/06/06 05:44:43 evansz2 Exp $
 *  Starting code: Phil Nelson
 *  Zach Evans
 *  CSCI 352
 *  Spring 2014
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include "proto.h"

int mainargc;
char **mainargv;
int shiftIndex;
int lastExit;
int interactive;
int waitingCPID;
int hadSigInt;
/* Constants */

FILE *inFile;
int outputfd;
FILE *errFile;

/* Prototypes */

int processline (char *line, int infd, int outfd, int flags);

char* findPipeChar(char *line){
	int inQuote = 0;
	int i;
	int lineLen = strlen(line);
	char c;
	for (i = 0; i < lineLen; i++){
		c = line[i];
		if(c== '"'){
			inQuote = !inQuote;
		}
		else if(!inQuote && (c =='|')){
			return &line[i];
		}
	}
	return NULL;
}

void removeComments(char* line){
	int inQuote = 0;
	int i;
	int lineLen = strlen(line);
	char c;
	for (i = 0; i < lineLen; i++){
		c = line[i];
		if (c == '#' && !inQuote){
			line[i] = '\0';
			return;
		}
		else if(c== '"'){
			inQuote = !inQuote;
		}
	}
	return;
}

/*SIGINT handler*/
void sigintHandler(int signum){
	hadSigInt = 1;
	if (waitingCPID){
		kill(waitingCPID, SIGINT);
	}
}

/* Shell main */

int
main (int argc, char **argv)
{
    char   buffer [LINELEN];
    int    len;
    interactive = 1;
    mainargc = argc;
    mainargv = argv;
    outputfd = 1;
    errFile = stderr;
    shiftIndex = 0;
    lastExit = 0;
	hadSigInt = 0;
	signal(SIGINT, sigintHandler);

    if (argc == 1){
      inFile = stdin;
    }

    else if(argc >= 2){
      interactive = 0;
      inFile = fopen(mainargv[1], "r");
      if (inFile == NULL){
        fprintf(errFile, "Couldn't open file: %s\n", mainargv[1]);
        exit(127);
      }
    }


  
  while (1) {

  hadSigInt = 0;
        /* prompt and get line */
  if (interactive){
	  char *prompt = getenv("P1");
	  if (prompt == NULL){
	   	fprintf (errFile, "%% ");
	   }
	   else{
		   fprintf(errFile,"%s", prompt);	
	   }
   }
	if (fgets (buffer, LINELEN, inFile) != buffer)
	  break;

        /* Get rid of \n at end of buffer. */
	len = strlen(buffer);
	if (buffer[len-1] == '\n')
	    buffer[len-1] = 0;

	/* Run it ... */
	processline (buffer,0,outputfd, 3);

  }

    if (!feof(inFile))
        perror ("read");

    return 0;		/* Also known as exit (0); */
}

int processline (char *line, int infd, int outfd, int flags)
{
	/*
	return values:
	-1 error
	0 no child to wait on
	>0 pid of child
	*/
    pid_t  cpid; //Child pid
    int    status; //argument for the wait() function
    int bi; //Int to see if builtin command was run
	char ** lineArgs; //array of arguments to the line
    char expanded[LINELEN];
	bzero(expanded, LINELEN);
	char *expandedPtr = expanded;
	
	int cinfd = infd;
	int coutfd = outfd;
	int cerrfd = 2;
	
	
	//Clean up zombies
	while(wait3(&status, WNOHANG, 0) > 0);
	
	
	removeComments(line);
	
	
	if (flags&0x02){
	    memset(expanded, 0, LINELEN); //Zero out expanded
	    int expandCheck = expand(line, expanded, LINELEN);
	    if (expandCheck < 0){
	      return -1;
	    }
	}
	else{
		memcpy(expanded, line, strlen(line));
	}
	
	//Pipelines
	char *pipeLoc;
	int pipefd[2];
	int tempRead = infd;
	int pipeFlag = 0;
	
	while ((pipeLoc=findPipeChar(expandedPtr)) != NULL){
		pipeFlag = 1;
		*pipeLoc = '\0';
		if (pipe(pipefd) < 0){
			dprintf(cerrfd, "Pipe error: %s\n", strerror(errno));
		}
		cpid = processline(expandedPtr, tempRead, pipefd[1], 0);
		if (tempRead != infd){
			close(tempRead);
		}
		tempRead = pipefd[0];
		close(pipefd[1]);
		expandedPtr = ++pipeLoc;
		
	}
	if (pipeFlag){
		cpid = processline(expandedPtr, tempRead, outfd, 1);
		close(tempRead);
		return cpid;
	}
	
	
	//Redirection
	
	if (findRedirections(expandedPtr, &cinfd, &coutfd, &cerrfd) < 0){
		return -1;
	}
	
	
    int numArgs = arg_parse(expandedPtr, &lineArgs);
    if (numArgs < 0){
      return -1;
    }
    else if(numArgs == 0){ //If there are zero arguments, don't process the line
      free(lineArgs);
      return 0;
    }


    bi = runBuiltin(numArgs, lineArgs, coutfd, cinfd, cerrfd);
    if (bi){ //Command was a builtin command
      free(lineArgs);
      return 0;
    }

    /* Start a new process to do the job. */
    cpid = fork();
    if (cpid < 0) {
      perror ("fork");
	    free(lineArgs);
      return -1;
    }

    /* Check for who we are! */
    if (cpid == 0) {
      /* We are the child! */
		
	  
		/* add dup2*/
	  if (cinfd != 0){
	
		dup2(cinfd, 0);
	  } 
	  if(coutfd != 1){

	  	dup2(coutfd,1);
	  }
	  if (cerrfd != 2){

		  dup2(cerrfd, 2);
	  }
	 
      execvp(lineArgs[0], lineArgs);
      perror ("exec");
	  free(lineArgs);
      exit (127);
    }
    else{
    	free(lineArgs);
		if (cinfd != infd){
			close(cinfd);
		}
    }
	if (flags&0x01){
	    /* Have the parent wait for child to complete */
		waitingCPID = cpid;
	    if (waitpid(cpid, &status, 0) < 0)
	      perror ("wait");
		waitingCPID = 0;
		if (WIFEXITED(status)){
			lastExit = WEXITSTATUS(status);
		}
		else{
			lastExit = 127;
		}
		return 0;
	}	
	return cpid;
}
