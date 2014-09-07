/* CS 352 -- Mini Shell!
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
#include "proto.h"


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

void processline (char *line)
{
    pid_t  cpid; //Child pid
    int    status; //argument for the wait() function
    int bi; //Int to see if builtin command was run
	  char ** lineArgs; //array of arguments to the line

    int numArgs = arg_parse(line, &lineArgs);
    if (numArgs < 0){
      return;
    }
    else if(numArgs == 0){ //If there are zero arguments, don't process the line
      free(lineArgs);
      return;
    }


    bi = runBuiltin(numArgs, lineArgs);
    if (bi){
      return;
    }

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

    /* Have the parent wait for child to complete */
    if (wait (&status) < 0)
      perror ("wait");
}
