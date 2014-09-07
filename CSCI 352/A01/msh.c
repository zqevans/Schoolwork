/* CS 352 -- Mini Shell!
 *
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


/* Constants */

#define LINELEN 1024

/* Prototypes */

void processline (char *line);

/* Shell main */

int
main (void)
{
    char   buffer [LINELEN];
    int    len;

    while (1) {


        /* prompt and get line */
	fprintf (stderr, "%% ");
	if (fgets (buffer, LINELEN, stdin) != buffer)
	  break;

        /* Get rid of \n at end of buffer. */
	len = strlen(buffer);
	if (buffer[len-1] == '\n')
	    buffer[len-1] = 0;

	/* Run it ... */
	processline (buffer);

    }

    if (!feof(stdin))
        perror ("read");

    return 0;		/* Also known as exit (0); */
}

char ** arg_parse (char *line){
	int argCount = 0; //Number of arguments in the line
	int inArg = 0; //Flag to check if parser is in argument
	char *ptr = line; //Pointer to traverse the arguments
	char c; //Character to be filled in with argument traversal
	int idx = 0; //Index in malloc'ed area
	while ((c = *ptr) != 0){ //Loop through and count args

		if (c == ' ' && inArg){ //Found first space after non-spaces
			 inArg = 0;
		 }
		 else if((c != ' ') && !inArg){ //Found arg
			 argCount++;
			 inArg = 1;
		 }
		 ptr++;
	}
	char ** argArray = (char **)malloc(sizeof(char *) * (argCount+1)); //Null-terminated array of pointers to argument characters
	if (argArray == NULL){
		perror("Malloc");
		return NULL;
	}
	ptr = line; //Reset the pointer
	inArg = 0;

	while ((c = *ptr) != 0){ //Loop through and add zero-characters and add to array
		if (c==' ' && inArg){
			inArg = 0;
			*ptr = 0;
		}
		else if(c != ' ' && !inArg){
			inArg = 1;
			argArray[idx] = ptr;
			idx++;
		}
		ptr++;
	}
	argArray[argCount] = NULL; //Set null-terminator on array
	return argArray;

}

void processline (char *line)
{
    pid_t  cpid;
    int    status;

	  char ** lineArgs = arg_parse(line);

    /* Start a new process to do the job. */
    cpid = fork();
    if (cpid < 0) {
      perror ("fork");
	    free(lineArgs);
      return;
    }

    /* Check for who we are! */
    if (cpid == 0) {
      /* We are the child! */
      execvp(lineArgs[0], lineArgs);
      perror ("exec");
	    free(lineArgs);
      exit (127);
    }
  	else{
  		free(lineArgs);
  	}

    /* Have the parent wait for child to c  omplete */
    if (wait (&status) < 0)
      perror ("wait");
}
