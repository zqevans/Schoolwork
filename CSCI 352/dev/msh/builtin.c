/* CS 352 -- Builtin commands
 *  $Id: builtin.c,v 1.22 2014/06/06 05:44:43 evansz2 Exp $
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
#include <sys/stat.h>
#include <ctype.h>
#include <time.h>
#include <pwd.h>
#include <grp.h>
#include "proto.h"

#define NUM_COMMANDS 9


static int isNum(char *numStart){
  int isDigit = 1;
  char c;
  while ((c = *numStart++) != '\0'){
    if (!isdigit(c)){
      isDigit = 0;
    }
  }
  return isDigit;
}

int aecho(int argc, char ** argv, int outfd, int infd, int errfd){
    int nMode = 0;
    int first = 1;
    if (argc == 0){
      dprintf(outfd,"\n");
      return 0;
    }
    if (argc > 1 && strncmp("-n", argv[1], 2) == 0){
      nMode = 1;
    }
    int idx = nMode?2:1;

    for (; idx < argc; idx++){
      if (first){

        dprintf(outfd,"%s", argv[idx]);
        first = 0;
      }
      else{
        dprintf(outfd, " %s", argv[idx]);
      }
    }
    if (!nMode){
      dprintf(outfd, "\n");
    }
    return 0;
}

int exitCommand(int argc, char ** argv, int outfd, int infd, int errfd){
  if (argc == 1){
    exit(0);
  }
  else if (argc == 2){
    exit(atoi(argv[1]));
  }
  else{
    dprintf(outfd, "Usage: exit [status]\n");
    return 1;
  }
  return 0;
}

int envset(int argc, char ** argv, int outfd, int infd, int errfd){
  if (argc == 3){
    setenv(argv[1], argv[2], 1);
  }
  else{
    dprintf(outfd, "Usage: envset NAME value\n");
    return 1;
  }
  return 0;
}

int envunset(int argc, char ** argv, int outfd, int infd, int errfd){
  if (argc == 2){
    unsetenv(argv[1]);
  }
  else{
    dprintf(outfd, "Usage: envunset NAME\n");
    return 1;
  }
  return 0;
}

int cd(int argc, char ** argv, int outfd, int infd, int errfd){
  /*
  Changes the working directory to dir. Changes working directory to environment
  variable HOME if set. Error otherwise.
  Usage: cd [dir]
  */

  if (argc == 1){
    char *home;
    if ((home = getenv("HOME"))){
      chdir(home);
    }
    else{
      dprintf(errfd, "No home directory specified.\n");
      return 1;
    }
  }
  else{
    if (chdir(argv[1])<0){
      dprintf(errfd, "%s\n",strerror(errno));
      return 1;
    }

  }
  return 0;
}

int shift(int argc, char **argv, int outfd, int infd, int errfd){
  /*
  Shifts $n arguments by index n. Shifts by 1 if called without arguments.
  Usage: shift [n]
  */
  int inShift;

  if(argc == 1){
    inShift = 1;
  }
  else if (argc == 2 && isNum(argv[1])){
    inShift = atoi(argv[1]);
  }
  else{
    dprintf(outfd, "Usage: shift [n]\n");
    return 1;
  }
  if(inShift >= (mainargc-1-shiftIndex)){
    dprintf(outfd,"Shift index too high\n");
    return 1;
  }
  
  shiftIndex += inShift;
  return 0;
}

int unshift(int argc, char **argv, int outfd, int infd, int errfd){
  /*
  Shifts $n arguments back by index n. Resets shift index if called without arguments.
  Usage: unshift [n]
  */
  if(argc == 1){
    shiftIndex = 0;
    return 0;
  }
  else if(argc == 2 && isNum(argv[1])){
    int inShift = atoi(argv[1]);
    if (inShift > shiftIndex){
      dprintf(outfd, "Shift index too high\n");
      return 1;
    }
    else{
      shiftIndex -= inShift;
    }
  }
  return 0;
}

int sstat(int argc, char **argv, int outfd, int infd, int errfd){
  /*
  Shows statistics for files given in arguments
  file-name user-name group-name permission-list num-links filesize modification-time
  Usage: sstat file [file...]
  */
  struct stat fileStat;
  struct passwd *userStruct;
  struct group *groupStruct;
  char *userPrint;
  char *groupPrint;
  char *filePrint;

  if (argc <= 1){
    dprintf(outfd, "Usage: sstat file [file...]\n");
    return 1;
  }
  else{
    int i;
    for (i = 1; i <= argc-1; i++){
      if (stat(argv[i], &fileStat) < 0){
        dprintf(outfd, "Invalid file name: %s\n", argv[i]); /*Bad file name given*/
		return 1;  
      }
      else{
        userStruct = getpwuid(fileStat.st_uid);
        groupStruct = getgrgid(fileStat.st_gid);
        if (userStruct != NULL){ /* Set User name or uid */
          userPrint = userStruct->pw_name;
        }
        else{
          snprintf(userPrint, 12, "%i", fileStat.st_uid);
        }

        if (groupStruct != NULL){ /*Set Group name or gid */
          groupPrint = groupStruct->gr_name;
        }
        else{
          snprintf(groupPrint, 12, "%i", fileStat.st_gid);
        }

		if (S_ISBLK(fileStat.st_mode)){ /* File type flag */
			filePrint = "b";
		}
		else if (S_ISCHR(fileStat.st_mode)){
			filePrint = "c";
		}
		else if (S_ISDIR(fileStat.st_mode)){
			filePrint = "d";
		}
		else if(S_ISLNK(fileStat.st_mode)){
			filePrint = "l";
		}
		else if(S_ISSOCK(fileStat.st_mode)){
			filePrint = "s";
		}
		else if(S_ISFIFO(fileStat.st_mode)){
			filePrint = "p";
		}
		else if(S_ISREG(fileStat.st_mode)){
			filePrint = "-";
		}
		else{
			filePrint = "?";
		}

        dprintf(outfd, "%s %s %s %s%s%s%s%s%s%s%s%s%s %lu %llu %s",argv[i],\
			 userPrint,groupPrint,filePrint,\
				 ((fileStat.st_mode & S_IRUSR)?"r":"-"),\
					 ((fileStat.st_mode & S_IWUSR)?"w":"-"),\
						 ((fileStat.st_mode & S_IXUSR)?"x":"-"),\
							 ((fileStat.st_mode & S_IRGRP)?"r":"-"),\
								 ((fileStat.st_mode & S_IWGRP)?"w":"-"),\
									 ((fileStat.st_mode & S_IXGRP)?"x":"-"),\
										 ((fileStat.st_mode & S_IROTH)?"r":"-"),\
											 ((fileStat.st_mode & S_IWOTH)?"w":"-"),\
												 ((fileStat.st_mode & S_IXOTH)?"x":"-"), \
													 (unsigned long)fileStat.st_nlink,\
														 (unsigned long long)fileStat.st_size,\
															 asctime(localtime(&fileStat.st_mtime)));
      }
    }
  }
  return 0;

}

int readCommand(int argc, char **argv, int outfd, int infd, int errfd){
	/*
	Reads in a line from standard input and puts it in an environment variable
	Usage: read [variable name]
	*/
	char inputBuffer[LINELEN]; //Buffer to hold the variable
	int bufLen = 0;
	char c = 0;
	if (argc != 2){
		dprintf(errfd, "Usage: read [variable name]\n");
		return 1;
	}
	
	while(c != '\n' && bufLen < LINELEN){
		bufLen += read(infd, &inputBuffer[bufLen], 1);
		c = inputBuffer[bufLen - 1];
	}
	
	
	inputBuffer[bufLen - 1] = 0; //Add null terminator
	if(setenv(argv[1], inputBuffer, 1) < 0){
		dprintf(errfd, "Environment Variable Error: %s\n", strerror(errno));
		return 1;
	}
	return 0;
	
	
}

static const char *commandNames[NUM_COMMANDS] = {"aecho", "exit", "envset", "envunset", "cd", "shift", "unshift", "sstat", "read"};
static int (*commandList[NUM_COMMANDS])(int, char **, int, int, int) = {&aecho, &exitCommand, &envset, &envunset, &cd, &shift, &unshift, &sstat, &readCommand};

int runBuiltin(int argc, char **argv, int outfd, int infd, int errfd){
  int ran = 0;
  int i;
  char *name = argv[0];
  for(i = 0; i<NUM_COMMANDS;i++){
    if (strcmp(name, commandNames[i]) == 0){
      int exitStatus = commandList[i](argc, argv, outfd, infd, errfd);
      lastExit = exitStatus;
      ran = 1;
    }
  }
  return ran;
}
