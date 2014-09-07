/* CS 352 -- Builtin commands
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
#include "proto.h"

#define NUM_COMMANDS 2




void aecho(int argc, char ** argv){
    int nMode = 0;
    int first = 1;
    if (argc == 0){
      printf("\n");
      return;
    }
    if (argc > 1 && strncmp("-n", argv[1], 2) == 0){
      nMode = 1;
    }
    int idx = nMode?2:1;

    for (; idx < argc; idx++){
      if (first){

        dprintf(1,"%s", argv[idx]);
        first = 0;
      }
      else{
        dprintf(1, " %s", argv[idx]);
      }

    }
    if (!nMode){
      dprintf(1, "\n");
    }
}

void exitCommand(int argc, char ** argv){
  if (argc == 1){
    exit(0);
  }
  else if (argc == 2){
    exit(atoi(argv[1]));
  }
  else{
    printf("Usage: exit [status]\n");
  }

}

static const char *commandNames[NUM_COMMANDS] = {"aecho", "exit"};
static void (*commandList[NUM_COMMANDS])(int, char **) = {&aecho, &exitCommand};

int runBuiltin(int argc, char **argv){
  int ran = 0;
  int i;
  char *name = argv[0];
  for(i = 0; i<NUM_COMMANDS;i++){
    if (strcmp(name, commandNames[i]) == 0){
      commandList[i](argc, argv);
      ran = 1;
    }
  }
  return ran;
}
