#! /usr/bin/bash



#mem=1024

re='[a-zA-Z]'
num='[0-9]'

list=() #liste für die tasks

###functions###

#returns pot space used for the 
function allocateCalc() {   #mem, task
    
    local mem=$1
    local task=$2
    
    while [ "$task" -le "$mem" ] #-le da task in memory passen soll
        
        do  
           mem=$(("$mem"/2))    #teilt solange bis passt
           
        done
    
    mem=$(("$mem"*2)) #dann ein mal verdoppeln
    echo "$mem"
}
#nächst kleinere Zweierpotenzmenge einer Zahl finden,benötigt für checkIfSpace()
function nextSmallerPot() {
    
    local memory=$1
    local countUp=1
    
    while [[ $countUp -le $memory ]]
    do  
        countUp=$(("$countUp"*2))
    done
    countUp=$(("$countUp"/2))
    
    echo "$countUp"
}



#checks if enough POT!!memory is left for task
function checkIfSpace() {   #task, memleft
    
    local task=$1
    local memory=$2
    local calcMem=$(nextSmallerPot "$memory")
    

    if [ "$calcMem" -ge "$task" ]
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


# checks how much memory is left (calculates mem-all active tasks)
function memleft() {
    local mem=$1 #same as mem, might not need argument
    local potmemused=0
    for elem in ${list[@]}  #adds all tasks up to see how much memory is used
    do 
        potmemused=$(($potmemused+$elem))
    done
    
    local memleft=$(($mem-$potmemused)) #gesamt memory - summe aller tasks
    echo "$memleft"
}


# löscht tasks aus liste
function deallocate() {
    local taskindx=$1 #index des tasks den man beenden will

    if [ "$taskindx" -gt ${#list[@]} ] || [ "$taskindx" -lt 0 ] #checkt ob die eingegebene zahl überhaupt index der liste ist oder ob eingegebene zahl kleiner 0
    then 
        echo "Task $taskindx doesn't exist" #wenn task nicht teil der liste ist
    else
        local ind="$taskindx-1" #wenn task teil der liste ist wird er aus der liste gelöscht
        unset list["$ind"] #//noch nicht sicher ob funktioniert

        echo "Task $taskindx deallocated"
        listClone=("${list[@]}") #unset löscht array element nicht sondern ersetzt es durch null, deshalb wird array auf ein neues kopiert, sodass null werte raus fallen
        list=("${listClone[@]}") #list wieder zurück kopieren, da mit list gearbeitet wird
    fi
    
}

# checkt ob Zweierpotenz
function checkIfPowerOfTwo() {

    n=$1
    (( n > 0 && (n & (n - 1)) == 0 )) #von so, keine ahnung was hier returned wird?############remove###############https://unix.stackexchange.com/questions/481552/check-if-numbers-from-command-line-are-powers-of-2/481558
}

# check0=true #wichtig für while loops
# check1=true #same
# initCheck=true

###main###
while true 
do
    read -p "Speicher eingeben" memoryInput
    mem=$memoryInput
    if [[ "$memoryInput" =~ $num ]] && checkIfPowerOfTwo "$memoryInput" = true
    then 

        while true
        do 
            read -p "Task (a)llocaten, Task (d)eallocate, alle (T)asks anzeigen oder (e)xit" inp
            #check1=true
            if [ "$inp" = "a" ] || [ "$inp" = "allocate" ]
            then
            
                while true
                do
                    read -p "Allocate Wert eingeben" allocateInput
                    if [[ "$allocateInput" =~ $re ]]
                    then
                    
                        printf "\nEingabewert muss eine Zahl sein\n"
                        echo " "
                        break
                        
                    fi
                    if [ $allocateInput -le 0 ]
                    then
                        
                        printf "\nKann keinen Task kleiner/gleich 0 allocaten (macht keinen sinn)\n"
                        echo ""
                    else
                        echo ""
                        memoryLeft=$(memleft "$mem") #wie viel memory ist left
                        #echo "memoryLeft before allocate: $memoryLeft"#######testing
                        #echo "mem $mem"#####testing
                        #declare -i pot=$(nextSmallerPot "$memoryLeft")
                        allocateCheck=$(checkIfSpace "$allocateInput" "$memoryLeft") #ist genug memory left für den task(allocateInput)
                        #echo "allocate check: $allocateCheck"####testing
                        if [ "$allocateCheck" = true ]
                        then
                            
                            temp=$(allocateCalc "$mem" "$allocateInput") #rechnet wie viel "potenzspeicher" für den task benötigt wird
                            #echo "temp: $temp"####testing
                            list+=("$temp") #fügt potenzspeicher in liste ein
                            echo "Task ($allocateInput) allocated: Task used $temp memory"
                            memoryLeft=$(memleft "$mem") #rechnet memory left, nachdem task in liste eingetragen wurde, aus
                            #echo "Memory left: $memoryLeft"####testing
                            #echo "mem $mem"####testing
                            echo ""
                            #check1=false #man kommt eine while loop zurück###egal
                            break
                        else
                            echo "$allocateInput not allocated - not enough memory left"
                            echo ""
                            #check1=false
                            break
                        fi
                    fi
                done
            elif [ "$inp" = "t" ] || [ "$inp" = "show tasks" ] || [ "$inp" = "tasks" ]
            then
                echo ""
                echo "Active tasks: ${list[@]}"
                echo ""
                memleee=$(memleft "$mem")
                echo "Remaining Memory: $memleee"
                singleTaskMem=$(nextSmallerPot "$memleee")
                echo "Höchst mögliche single task size: $singleTaskMem"
                echo ""
            elif [ "$inp" = "d" ] || [ "$inp" = "deallocate" ]
            then
                read -p "Welchen Task deallocaten?" deallocInput

                if ! [[ $deallocInput =~ $num ]]
                then
                    echo " "
                    echo "Eingabewert muss eine Zahl sein"
                    echo " "
                    #break
                else
                    echo ""
                    deallocate "$deallocInput"
                
                    echo "Remaining active tasks: ${list[@]}"
                    memleee=$(memleft "$mem")
                    echo "Remaining Memory: $memleee"
                    echo ""
                fi
            elif [ "$inp" = "e" ] || [ "$inp" = "exit" ] #end program
            then
                echo "Programm beendet"
                exit 1
             elif [ "$inp" = "mem" ]
            then
                echo "mem $mem"
                memleee=$(memleft "$mem")
                echo "memLeft $memleee"
                singleTaskMem=$(nextSmallerPot "$memleee")
                echo "Höchst mögliche single task size: $singleTaskMem"
            else
                echo "Command nicht erkannt - bitte erneut eingeben"
            fi
        done
    else
        echo " "
        echo "Eingabe muss eine Zweierpotenz sein"
        echo " "
    fi
done
