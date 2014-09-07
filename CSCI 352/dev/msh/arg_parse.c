/* CS 352 -- Argument parsing function
 *  $Id: arg_parse.c,v 1.2 2014/04/22 02:08:08 evansz2 Exp $
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


int arg_parse (char *line, char ***argvp){
  int argCount = 0; //Number of arguments in the line
  //int inArg = 0; //Flag to check if parser is in argument
  //int inQuote = 0;
  char *ptr = line; //Pointer to traverse the arguments
  char c; //Character to be filled in with argument traversal
  int idx = 0; //Index in malloc'ed area
  int state = 0;
  /*
  States:
  0: out of argument
  1: argument starts with quote (not used in counting args)
  2: in an argument
  3: in a quote
  4: checking for null argument
  */

  while ((c = *ptr) != 0){ //Count arguments
    if (state == 0){
      if (c == '"'){
        argCount++;
        state = 3;
      }
      else if(c !=' '){
        argCount++;
        state = 2;
      }
    }
    else if(state == 2){
      if (c == '"'){
        state = 3;
      }
      else if(c == ' '){
        state = 0;
      }
    }
    else if(state == 3){
      if(c == '"'){
        state = 2;
      }
    }
    ptr++;
  }

  if (state == 3){ //Odd number of quotes found
    dprintf(1, "Odd number of quotes found in line\n");
    return -1;
  }
  char ** argArray = (char **)malloc(sizeof(char *) * (argCount+1)); //Null-terminated array
                                                            //of pointers to argument letters
  if (argArray == NULL){
    perror("Malloc");
    return -1;
  }
  ptr = line; //Reset the pointer
  char *dst = line;
  state = 0;


  while ((c = *ptr) != 0){ //Add zero-characters and pointers, removing quotes

    if (state == 0){  //Outside of an argument
      if (c == '"'){
        state = 1;
      }
      else if (c != ' '){
        state = 2;
        *dst = c;
        argArray[idx] = dst;
        dst++;
        idx++;
      }
    }
    else if(state == 1){ //Argument starting with a quote
      if (c == '"'){
        state = 4;
      }
      else{
        state = 3;
        argArray[idx] = dst;
        *dst = c;
        dst++;
        idx++;
      }
    }
    else if(state == 2){ //in an argument, not in a quote
      if(c == ' '){ //End of argument
          state = 0;
          *dst = '\0';
          dst++;
      }
      else if(c == '"'){//Entering a quote
        state = 3;
      }
      else{
        *dst = c;
        dst++;
      }
    }
    else if(state == 3){//in a quote in an argument
      if(c == '"'){
        state = 2;
      }
      else{
        *dst = c;
        dst++;
      }
    }
    else if(state == 4){//Two quotes in a row while not in an argument
      if(c =='"'){
        state = 1; //Argument still hasn't started, back in a quote
      }
      else if(c==' ') //Null argument
      {
        state = 0;
        *dst = '\0';
        argArray[idx] = dst;
        dst++;
        idx++;
      }
      else{ //argument after even number of quotes
        state = 2;
        *dst = c;
        argArray[idx] = dst;
        dst++;
        idx++;
      }
    }
    ptr++;
  }
  *dst = 0;
  argArray[argCount] = NULL;
  *argvp = argArray;
  return argCount;
}
