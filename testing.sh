# #! /usr/bin/bash



# mem=1024

# # a=6
# # b=2
# # a=$(($a/2))
# # #echo $(($a/$b))
# # echo "a = $a"

# list=()


# #returns pot space used for the task
# function allocateCalc() {   #mem, task
    
#     local mem=$1
#     local task=$2
    


#     while [ "$task" -le "$mem" ]
        
#         do  
#            mem=$(("$mem"/2))
           
#         done
    
#     mem=$(($mem*2))
#     echo "$mem"
# }

# ero=$(allocateCalc $mem 0)
# echo $ero
# # ree=$(memleft 1024)
# # echo "memleft: $ree"




# #checks if enough memory is left for task
# function checkIfSpace() {   #task, memleft
    
#     local task=$1
#     local memleft=$2
    
#     if [ $memleft -ge $task ]
#     then 
#         local check=true
#     else
#         local check=false
#     fi
#     echo "$check"        
# }




# function allocate() {
#     list+=("$1")

# }
# # checks how much memory is left (calculates mem-all active tasks)
# function memleft() {
#     local mem=$1 #same as mem, might not need argument
#     local potmemused=0
#     for elem in ${list[@]}  #adds all tasks up to see how much memory is used
#     do 
#         potmemused=$(($potmemused+$elem))
#     done
    
#     local memleft=$(($mem-$potmemused)) #gesamt memory - summe aller tasks
#     echo "$memleft"
# }



# # löscht tasks aus liste
# function deallocate() {
#     local taskindx=$1 #index des tasks den man beenden will

#     if [ "$taskindx" -gt ${#list[@]} ] || [ "$taskindx" -lt 0 ] #checkt ob die eingegebene zahl überhaupt index der liste ist oder ob eingegebene zahl kleiner 0
#     then 
#         echo "Task $taskindx doesn't exist" #wenn task nicht teil der liste ist
#     else
#         local ind="$taskindx-1" #wenn task teil der liste ist wird er aus der liste gelöscht
      
#         unset list["$ind"] #//noch nicht sicher ob funktioniert
#     fi
#     #echo "$list"
# }
# ##############################################################################################
# # check0=true #wichtig für while loops
# # check1=true #same


# # while [ $check0 = true ]
# # do 
# #     read -p "allocate or deallocate or show tasks" inp
# #     check1=true
# #     if [ "$inp" = "a" ]
# #     then
# #         echo ":)"
# #         while [ $check1 = true ]
# #         do
# #             read -p "allocate wert eingeben" allocateInput
# #             memoryLeft=$(memleft "$mem") #wie viel memory ist left
# #             echo "memory left before allocate: $memoryLeft"
# #             allocateCheck=$(checkIfSpace "$allocateInput" "$memoryLeft") #ist genug memory left für den task(allocateInput)
# #             echo "allocate check: $allocateCheck"
# #             if [ "$allocateCheck" = true ]
# #             then
                
# #                 temp=$(allocateCalc "$mem" "$allocateInput") #rechnet wie viel "potenzspeicher" für den task benötigt wird
# #                 list+=("$temp") #fügt potenzspeicher in liste ein
# #                 echo "$allocateInput allocated: Task used $temp memory"
# #                 memoryLeft=$(memleft "$mem") #rechnet memory left, nachdem task in liste eingetragen wurde, aus
# #                 echo "Memory left: $memoryLeft"
# #                 check1=false #man kommt eine while loop zurück //bleibt denke nicht so drin

# #             else
# #                 echo "$allocateInput not allocated - not enough memory left"
# #                 check1=false
# #             fi
# #         done
# #     elif [ "$inp" = "t" ] 
# #     then
# #         echo "active tasks: ${list[@]}"
    
# #     else
# #         echo "kkkkeeekk"
# #     fi
# # done

# #read -p "Enter your name: " NAME
# #echo "hey $NAME, $result"
# ##############################################################################################

# res=$(allocateCalc 1024 128)
# res=$(($res+22))
# echo "allocatecalc: $res"


# # allocate 120
# # allocate 240
# # allocate 510
# # allocate 513
# # echo "allocate ${list[@]}"

# # ree=$(memleft 1024)
# # echo "memleft: $ree"

# # echo "${list[@]}"

# # deallocate 4
# # echo "${list[@]}"


# my_array=(1 2 3)
# unset my_array[1]
# echo ${my_array[@]}
# for host in {!my_array[@]}
#     echo