#!/bin/bash

SOURCE_FILES_PATH=~/share/tasks/

# reset dictionary file
echo -n "set dictionary=/usr/share/dict/words," > ~/.vim/.vimrc.dictionary

# text files
# echo -n $(find ~/docs ~/work -name \*.txt -printf "%p," | sed 's/\ /\\/g') >> ~/.vim/.vimrc.dictionary

# source files
# echo -n $(find $SOURCE_FILES_PATH -name \*.cpp -printf "%p," | sed 's/\ /\\/g') >> ~/.vim/.vimrc.dictionary
echo -n $(find $SOURCE_FILES_PATH -name \*log.txt -printf "%p," | sed 's/\ /\\/g') >> ~/.vim/.vimrc.dictionary
