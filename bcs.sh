# chmod +x testing.sh
# which bash


#! /bin/bash

# ECHO COMMAND
# echo Hello World!

# VARIABLES
# Uppercase by convention
# Letters, numbers, underscores
# NAME="Bob"
# echo "My name is $NAME"
# echo "My name is ${NAME}"

# USER INPUT
# read -p "Enter your name: " NAME
# echo "Hello $NAME, nice to meet you!"

# SIMPLE IF STATEMENT
# if [ "$NAME" == "Brad" ]
# then
#   echo "Your name is Brad"
# fi

# IF-ELSE
# if [ "$NAME" == "Brad" ]
# then
#   echo "Your name is Brad"
# else 
#   echo "Your name is NOT Brad"
# fi

# ELSE-IF (elif)
# if [ "$NAME" == "Brad" ]
# then
#   echo "Your name is Brad"
# elif [ "$NAME" == "Jack" ]
# then  
#   echo "Your name is Jack"
# else 
#   echo "Your name is NOT Brad or Jack"
# fi

# COMPARISON
# NUM1=31
# NUM2=5
# if [ "$NUM1" -gt "$NUM2" ]
# then
#   echo "$NUM1 is greater than $NUM2"
# else
#   echo "$NUM1 is less than $NUM2"
# fi

########
# val1 -eq val2 Returns true if the values are equal
# val1 -ne val2 Returns true if the values are not equal
# val1 -gt val2 Returns true if val1 is greater than val2
# val1 -ge val2 Returns true if val1 is greater than or equal to val2
# val1 -lt val2 Returns true if val1 is less than val2
# val1 -le val2 Returns true if val1 is less than or equal to val2
########


# SWITCH CASE STATEMENT 
# read -p "Are you 21 or over? Y/N " ANSWER
# case "$ANSWER" in 
#   [yY] | [yY][eE][sS])
#     echo "You can have a beer :)"
#     ;;
#   [nN] | [nN][oO])
#     echo "Sorry, no drinking"
#     ;;
#   *)
#     echo "Please enter y/yes or n/no"
#     ;;
# esac

# FOR LOOP
# my_array=(3 5 6)
# for elem in ${my_array[@]}
# do
#      echo $elem
# done


# WHILE LOOP
# while [ $i -le 50000000 ]
#     do 
#         echo "number: $i"
#         ((i=i+1))
# done


# FUNCTION
# function sayHello() {
#   echo "Hello World"
# }
# CALL FUNCTION
# sayHello


# RETURN FUNCTION
# function test() {
#     local ret="I am $1$2$3"
#     echo "$ret" #this is the return statement - will not get printed
# }
# CALL THIS FUNCTION
# result=$(test "man""bear""pig")
# echo $result


# ARRAY
# array=(3 4 5)
# echo ${array[1]}

# ADD TO ARRAY
# $ my_array=(foo bar)
# $ my_array+=(baz)

# REMOVE ITEM FROM ARRAY - easy way
# $ my_array=(foo bar baz)
# $ unset my_array[1]
# $ echo ${my_array[@]}
# foo baz

# REMOVE ITEM FROM ARRAY
# removes everything after 2
# list=("${list[@]:0:2}")

# ARRAY LENGTH
# echo "${#distro[@]}"


# USER INPUT
# read -p "Enter your name: " NAME
# echo "hey $NAME"



