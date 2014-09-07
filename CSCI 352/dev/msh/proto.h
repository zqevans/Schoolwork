/* CS 352 -- Function prototypes
 * $Id: proto.h,v 1.13 2014/06/06 05:44:43 evansz2 Exp $
 *  Zach Evans
 *  CSCI 352
 *  Spring 2014
 */
#include <stdio.h>
#define LINELEN 200000

int arg_parse(char *line, char ***argvp);
int runBuiltin(int argc, char **argv, int outfd, int infd, int errfd);
int expand (char *orig, char *new, int newsize);
int processline (char *line, int infd, int outfd, int flags);
int findRedirections(char *line, int *infd, int *outfd, int *errfd);



extern int mainargc;
extern char **mainargv;
extern int shiftIndex;
extern int lastExit;
extern int interactive;
extern int hadSigInt;
extern int waitingCPID;