#! /usr/bin/bash



mem=1024

re='[a-zA-Z]'
num='[0-9]'

list=() #liste für die tasks

###functions###

#returns pot space used for the task
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


#checks if enough memory is left for task
function checkIfSpace() {   #task, memleft
    
    local task=$1
    local memleft=$2
    
    if [ "$memleft" -ge "$task" ]
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

        echo "task $taskindx deallocated"
        listClone=("${list[@]}") #unset löscht array element nicht sondern ersetzt es durch null, deshalb wird array auf ein neues kopiert, sodass null werte raus fallen
        list=("${listClone[@]}") #list wieder zurück kopieren, da mit list gearbeitet wird
    fi
    #echo "$list"
}

# function checkIfNumber() {
    
#     local c=true
#     local input=$1
#     if [[ "$input" =~ $re ]]
#             then
#                c=false
              
#     fi
#     echo "$c"
# }

check0=true #wichtig für while loops
check1=true #same

###main###
while [ true ]
do
    read -p "Speicher eingeben" memoryInput

    if [ $memoryInput = 1024 ]
    then 

        while [ $check0 = true ]
        do 
            read -p "allocate or deallocate or show tasks or exit" inp
            check1=true
            if [ "$inp" = "a" ] || [ "$inp" = "allocate" ]
            then
            
                while [ $check1 = true ]
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
                        #echo "memory left before allocate: $memoryLeft"
                        allocateCheck=$(checkIfSpace "$allocateInput" "$memoryLeft") #ist genug memory left für den task(allocateInput)
                        #echo "allocate check: $allocateCheck"
                        if [ "$allocateCheck" = true ]
                        then
                            
                            temp=$(allocateCalc "$mem" "$allocateInput") #rechnet wie viel "potenzspeicher" für den task benötigt wird
                            #   echo "temp: $temp"
                            list+=("$temp") #fügt potenzspeicher in liste ein
                            echo "Task ($allocateInput) allocated: Task used $temp memory"
                            memoryLeft=$(memleft "$mem") #rechnet memory left, nachdem task in liste eingetragen wurde, aus
                            echo "Memory left: $memoryLeft"
                            echo ""
                            #check1=false #man kommt eine while loop zurück
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
            elif [ "$inp" = "d" ] || [ "$inp" = "deallocate" ]
            then
                read -p "welchen task deallocaten?" deallocInput

                if ![ $deallocInput =~ $num ]
                then
                    echo "Muss Zahl sein"
                    break
                else
                    echo ""
                    deallocate "$deallocInput"
                
                    echo "Remaining active tasks: ${list[@]}"

                    echo ""
                fi
            elif [ "$inp" = "e" ] || [ "$inp" = "exit" ] #end program
            then
                echo "Programm beendet"
                exit 1
            else
                echo "Command not recognized - enter again"
            fi
        done
    else
        echo "Eingabe muss eine Zweierpotenz sein"
    fi
done
#read -p "Enter your name: " NAME
#echo "hey $NAME, $result"

#testing
# res=$(allocateCalc 1024 128)
# res=$(($res+22))
# echo "allocatecalc: $res"

# k=$(checkIfSpace 300 240)
# echo "checkifspace $k"

# allocate 120
# allocate 240
# allocate 510
# allocate 513
# echo "allocate ${list[@]}"

# ree=$(memleft 1024)
# echo "memleft: $ree"

# echo "${list[@]}"

# deallocate 4
# echo "${list[@]}"



##notes

#  if [[ "$allocateInput" =~ $re ]]
#             then
               
#                 printf "\nEingabewert muss eine Zahl sein\n"
#                 echo " "
#                 break
                
#             fi