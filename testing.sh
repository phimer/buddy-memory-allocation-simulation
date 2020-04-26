#! /usr/bin/bash

# echo "Hell World"


# NAME="Philip"


# if [ $NAME == "Philip" ]
# then
#     echo "Your name is $NAME, same as me"
# elif [ "$NAME" == "Jack" ]
# then
#     echo "Your name is $NAME, handsome"
# else
#     echo "Your name is weird"
# fi


# read -p "Enter your name: " NAME
# echo "Hello $NAME, nice to meet you!"


# val1 -eq val2 Returns true if the values are equal
# val1 -ne val2 Returns true if the values are not equal
# val1 -gt val2 Returns true if val1 is greater than val2
# val1 -ge val2 Returns true if val1 is greater than or equal to val2
# val1 -lt val2 Returns true if val1 is less than val2
# val1 -le val2 Returns true if val1 is less than or equal to val2


# FOR LOOP TO RENAME FILES
# FILES=$(ls *.txt)
# NEW="new"
# for FILE in $FILES  
#   do
#     echo "Renaming $FILE to new-$FILE"
#     mv $FILE $NEW-$FILE
# done

marray=(3 5 6)


# for elem in ${marray[@]}
# do
#      echo $elem
# done


# for i in ${marray[@]}
# do
#    echo "Welcome $i times"
# done

# i=1


# while [ $i -le 50000000 ]
#     do 
#         echo "number: $i"
#         ((i=i+1))
# done


# WHILE LOOP - READ THROUGH A FILE LINE BY LINE
# LINE=1
# while read -r CURRENT_LINE
#   do
#     echo "$LINE: $CURRENT_LINE"
#     ((LINE++))
# done < "./new-1.txt"


# array
# array=(3 4 5)
# echo ${array[1]}

# add to array
# $ my_array=(foo bar)
# $ my_array+=(baz)

# remove from array
# $ my_array=(foo bar baz)
# $ unset my_array[1]
# $ echo ${my_array[@]}
# foo baz


# FUNCTION
# function sayHello() {
#   echo "Hello World"
# }
# sayHello

# FUNCTION WITH PARAMS
# function greet() {
#   echo "Hello, I am $1 and I am $2"
# }

# greet "Brad" "36"


function test() {
    local ret="I am $1$2"
    echo "$ret"
}


result=$(test "bat" "man")
echo $result
#read -p "Enter your name: " NAME





