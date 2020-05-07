#! /usr/bin/bash



#mem=1024

re='[a-zA-Z]'
num='[0-9]'

list=() #liste für die tasks

###functions###

#returns potenzmenge für die tasks
function allocateCalc() {
    
    local mem=$1
    local task=$2
    
    while [ "$task" -le "$mem" ] #-le da task in memory passen soll
        
        do  
           mem=$(("$mem"/2))    #teilt solange bis passt
           
        done
    
    mem=$(("$mem"*2)) #dann ein mal verdoppeln
    echo "$mem"
}

#nächst kleinere Zweierpotenzmenge einer Zahl finden, benötigt für checkIfSpace()
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



#checks ob genug pot memory übrig ist um task auszuführen (nimmt nächst kleinere zweirpotenz von restlichem verfügbaren speicher, und checkt ob der task <= ist)
function checkIfSpace() {   #task, memleft
    
    local task=$1
    local memory=$2
    local calcMem=0
    calcMem=$(nextSmallerPot "$memory")
    

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


# checks wie viel speicher noch übrig ist (rechnet max speicher(der vom user am anfang eingegeben) - summe aller werte(tasks) in der liste)
function memleft() {
    local mem=$1 
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

# checkt ob Zweierpotenz, wichtig für erste user eingabe(eingabe muss zweierpotenz sein)
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
    read -p "Speicher eingeben" memoryInput #user input für speicher den programm haben soll
    mem=$memoryInput #mem bleibt immer dieser eingegeben original wert, wird zum rechnen benutzt
    if [[ "$memoryInput" =~ $num ]] && checkIfPowerOfTwo "$memoryInput" = true #user input muss zahl sein und muss zweierpotenz sein
    then 

        while true
        do 
            read -p "Task (a)llocaten, Task (d)eallocate, alle (T)asks anzeigen oder (e)xit" inp #"hauptmenü", user kann hier task allocaten, deallocaten, alle aktiven tasks anzeigen oder programm verlassen
            #check1=true
            if [ "$inp" = "a" ] || [ "$inp" = "allocate" ]  # wenn user einen task starten will (allocate)
            then
            
                while true
                do
                    read -p "Allocate Wert eingeben" allocateInput
                    if [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -gt 0 ] #input muss zahl sein und größer 0
                    then
                    
                        echo ""
                        memoryLeft=$(memleft "$mem") #wie viel memory ist left

                        #echo "memoryLeft before allocate: $memoryLeft"#######testing
                        #echo "mem $mem"#####testing
                        #declare -i pot=$(nextSmallerPot "$memoryLeft")

                        allocateCheck=$(checkIfSpace "$allocateInput" "$memoryLeft") #ist genug memory left für den task(allocateInput)
                        #echo "allocate check: $allocateCheck"####testing
                        if [ "$allocateCheck" = true ] #wenn genug platz für den task ist
                        then
                            
                            temp=$(allocateCalc "$mem" "$allocateInput") #rechnet wie viel "potenzspeicher" für den task benötigt wird
                            #echo "temp: $temp"####testing
                            list+=("$temp") #fügt potenzspeicher in liste ein
                            echo "Task ($allocateInput) allocated: Task used $temp memory"
                            memoryLeft=$(memleft "$mem") #rechnet memory left, nachdem task in liste eingetragen wurde, aus, eigentlich nur wichtig zum testen, kann wharscheinlich raus
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

                        
                        
                    
                    elif [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -le 0 ] #wenn eingabe zahl aber <= 0 bekommt user die meldung, dass es keinen sinn macht
                    then
                        
                        printf "\nKann keinen Task kleiner/gleich 0 allocaten (macht keinen sinn)\n"
                        echo ""
                    else
                        printf "\nEingabewert muss eine Zahl sein\n" #wenn eingabe keine pure zahl ist 
                        echo " "
                        break
                    fi
                done
            elif [ "$inp" = "t" ] || [ "$inp" = "show tasks" ] || [ "$inp" = "tasks" ] #wenn user alle aktiven tasks anzeigen lassen will
            then
                echo ""
                echo "Active tasks: ${list[@]}" #printed einfach liste aus (sind alle aktiven tasks)
                echo ""
                memleee=$(memleft "$mem") #info für user wie viel speicher noch übrig ist
                echo "Remaining Memory: $memleee"
                singleTaskMem=$(nextSmallerPot "$memleee") #info für user wie viel groß der größt mögliche task sein kann
                echo "Höchst mögliche single task size: $singleTaskMem"
                echo ""
            elif [ "$inp" = "d" ] || [ "$inp" = "deallocate" ] #wenn user einen task beenden will (deallocate)
            then
                read -p "Welchen Task deallocaten?" deallocInput

                if ! [[ $deallocInput =~ $num ]] #wenn task keine zahl ist 
                then
                    echo " "
                    echo "Eingabewert muss eine Zahl sein"
                    echo " "
                    #break
                else
                    echo ""
                    deallocate "$deallocInput" #diese funktion löscht den task aus der liste(wenn es diesen task gitb)(wird alles in function gecheckt)
                
                    echo "Remaining active tasks: ${list[@]}" #info für user welche tasks aktuell noch laufen
                    memleee=$(memleft "$mem")
                    echo "Remaining Memory: $memleee" #info für user wie viel gesamtspeicher noch frei ist
                    echo ""
                fi
            elif [ "$inp" = "e" ] || [ "$inp" = "exit" ] #end program
            then
                echo "Programm beendet"
                exit 1
            elif [ "$inp" = "mem" ] #nur zum testen
            then
                echo "mem $mem"
                memleee=$(memleft "$mem")#nur zum testen
                echo "memLeft $memleee"
                singleTaskMem=$(nextSmallerPot "$memleee")#nur zum testen
                echo "Höchst mögliche single task size: $singleTaskMem"#nur zum testen
            else #wenn user eingabe keines der oeberen commands ist (a, d, t, e) muss er erneut erwas eingeben
                echo "Command nicht erkannt - bitte erneut eingeben"
            fi
        done
    else
        echo " "
        echo "Eingabe muss eine Zweierpotenz sein" #else clause zu erster eingabe, wenn eingabe keine zweierpotenz ist
        echo " "
    fi
done
