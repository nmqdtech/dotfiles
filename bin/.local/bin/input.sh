#!/bin/bash

function get_input(){
  unset userinput 
  while read line
  do
    userinput+=$line'\n'
    [[ "$line" ]] || break
  done

  echo "You Entered:"
  echo -e $userinput
}

echo "Please Enter Some Text"
get_input
