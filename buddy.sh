#! /usr/bin/bash



mem=1024

# a=6
# b=2
# a=$(($a/2))
# #echo $(($a/$b))
# echo "a = $a"

list=()


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
    list+=("$1")

}

function memleft() {
    local mem=$1
    local potmemused=0
    for elem in ${list[@]}
    do 
        potmemused=$(($potmemused+$elem))
    done
    
    local memleft=$(($mem-$potmemused))
    echo "$memleft"
}

function deallocate() {
    local taskindx=$1

    if [ $taskindx -gt ${#list[@]} ] || [ $taskindx -lt 0 ]
    then 
        echo "Task $taskindx doesn't exist"
    else
        local ind="$taskindx-1"
      
        unset list["$ind"]
    fi
    #echo "$list"
}

check0=true
check1=true


while [ $check0 = true ]
do 
    read -p "allocate or deallocate" inp
    check1=true
    if [ "$inp" = "a" ]
    then
        echo ":)"
        while [ $check1 = true ]
        do
            read -p "allocate wert eingeben" allocateInput
            memoryLeft=$(memleft "$mem")
            echo "$memoryLeft"
            allocateCheck=$(checkIfSpace "$allocateInput" "$memoryLeft")
            echo "$allocateCheck"
            if [ "$allocateCheck" = true ]
            then
                
                temp=$(allocateCalc "$mem" "$allocateInput")
                list+=("$temp")
                echo "$allocateInput allocated: Task used $temp memory"
                memoryLeft=$(memleft "$mem")
                echo "Memory left: $memoryLeft"
                check1=false
            else
                echo "$allocateInput not allocated - not enough memory left"
                check1=false
            fi
        done
    else
        echo "kkkkeeekk"
    fi
done

#read -p "Enter your name: " NAME
#echo "hey $NAME, $result"


res=$(allocateCalc 1024 128)
res=$(($res+22))
echo "allocatecalc: $res"

k=$(checkIfSpace 300 240)
echo "checkifspace $k"

allocate 120
allocate 240
allocate 510
allocate 513
echo "allocate ${list[@]}"

ree=$(memleft 1024)
echo "memleft: $ree"

echo "${list[@]}"

deallocate 4
echo "${list[@]}"



