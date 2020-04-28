#! /usr/bin/bash

UNO=false

HARDMEM=1024
MEMORY=$HARDMEM
POTMEM=$HARDMEM

a=6
b=2
a=$(($a/2))
#echo $(($a/$b))
echo "a = $a"



#returns pot space used for the task
function allocateCalc() {   #mem, task
    
    local mem=$1
    local task=$2
    #mem=$(($mem/2))

    while [ $task -lt $mem ]
        
        do  
           mem=$(($mem/2))
           
        done
    
    mem=$(($mem*2))
    echo "$mem"
}


#checks if enough memory is left for task
function checkIfSpace() {   #task, memleft
    
    local task=$1
    local memleft=$2
    
    if [ $memleft -ge $task ]
    then 
        local check=true
    else
        local check=false
    fi
    echo "$check"        
}

function allocate() {
    
}

res=$(allocateCalc 1024 128)
res=$(($res+22))
echo $res

k=$(checkIfSpace 300 240)
echo $k



# IF-ELSE
# if [ "$NAME" == "Brad" ]
# then
#   echo "Your name is Brad"
# else 
#   echo "Your name is NOT Brad"
# fi


# echo $(allocateCalc 1024 120)
# AC=$(allocateCalc 1024 280)
# echo $AC
###############
# I=0
# function test() {
    
#     while [ $I -le 5 ]
#         do  
#             #echo $I
#             echo $(($1+3))
#             ((I=I+1))
#     done
# }

# test 3


# function myfunc()
# {
#     local  myresult='some value'
#     echo "$myresult"
# }

# result=$(myfunc)   # or result=`myfunc`
# echo $result
# echo $(myfunc)
# RETURN FUNCTION
# function test() {
#     local ret="I am $2$1$3"
#     echo "$ret"
# }

# result=$(test "bat""man""pig")
# echo $result

