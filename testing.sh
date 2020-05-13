#! /usr/bin/bash

echo -e "################################################################################################################################################################"
function devAdd()  {
    
    sumBuddy=0
    sumTask=0


    for el in "${buddylist[@]}"
    do
        sumBuddy=$(("$sumBuddy"+"$el"))
    done

    for elo in "${tasklist[@]}"
    do
        sumTask=$(("$sumTask"+"$elo"))
    done



    res=$(("$sumBuddy"+"$sumTask"))
  
    echo "devAdd: $res"
}


memory=1024

re='[a-zA-Z]'
num='[0-9]'

tasklist=() #liste für aktive tasks (befüllte buddys)
buddylist=() #liste für leere buddys
taskidlist=()
buddyidlist=()
declare -A idAssign

idCount=1

###functions###



function allocate() {

    local mem=$1    #1024
    local task=$2   #120
    local sizeCheck=$(("$mem"+1))
    local i=0
    local spaceLeftCheck=false
  

    if [ "${#buddylist[@]}" -eq 0 ] && [ "${#tasklist[@]}" -eq 0 ] #wenn die liste leer ist wird dieses verfahren benutzt
    then

        if [ "$task" -le "$mem" ]
        then
            while [ "$task" -le "$mem" ] #-le da task in memory passen soll
                
                do  
                mem=$(("$mem"/2))    #teilt solange bis passt
                if [ "$mem" -ge "$task" ] #solange der task noch kleiner als gesammt mem ist wird jede halbierung als leerer buddy in die liste geschrieben
                then
                    
                    buddylist+=("$mem") #leere buddys kommen in liste

                    buddyidlist+=("$idCount") #jede Teilung, also jeder buddy, bekommt seine id in der buddyidlist
                    
                    #dictionary für spätere rückwärtszuweisung
                    idCountMinusOne=$(("$idCount"-1))
                    idAssign["$idCount"]="$idCountMinusOne"
                    
                    echo "idAssign ${idAssign[@]}"
                    
                    
                    idCount=$(("$idCount"+1)) #idCount hochzählen

                fi       
                done
            
            mem=$(("$mem"*2)) #dann ein mal verdoppeln
            
            tasklist+=("$mem") #aktiver task kommt in die taskliste (hier mit mem gerechnet)
            echo -e "\e[32mTask $task erfolgreich allocated - benötigte $mem Speicher\e[0m"
            idCountMinusOne=$(("$idCount"-1))
            taskidlist+=("$idCountMinusOne")
        else
            echo -e "e[31mTask $task ist zu groß, nicht genug speicher verfügbar\e[0m"
        fi
    elif [ "${#buddylist[@]}" -gt 0 ] #sobald die erste allocation durchgeführt wurde, wird ab dann diese methode benutzt
    then
        #echo "else case"
        #FORLOOP
       
       
        for elem in "${buddylist[@]}" #hier wird die buddyliste(mit leeren buddys) durchlaufen, und nach dem kleinst möglichen buddy gesucht in den der task passt,
            #indem zum einen geschaut wird ob ein buddy größer(gleich) dem angeforderten task ist UND ob ein buddy kleiner als der buddy vor ihm in der liste ist
            #DIE BUDDYS WERDEN NACHEINANDER DURCHLAUFEN UND ÜBERSCHREIBEN SICH SO LANGE BIS DER KLEINSTE BUDDY PASST (oder einer der kleinsten wenn es mehrere gibt (-le))
        do 
            
            if [ "$elem" -ge "$task" ] && [ "$elem" -le "$sizeCheck" ] #task ist kleiner als elembuddy und elembuddy ist kleiner als der buddy vorher in der liste, ?sollte egal sein ob -le oder -lt?
            then   
                sizeCheck=$elem #wird benutzt um zu prüfen, dass bei Durchlaufen durch Liste ein kleines und passender buddy nicht durch einen größeren passenden buddy überschrieben wird (man will den kleinst möglichen buddy finden der von der größe her passt)
                
                local half=$(("$elem"/2)) #wird halbiert, im nächsten if wird damit weiter gearbeitet
                #echo "half $half"
                
                local indexForDelete=$i #element bei dem 
                i=$(("$i"+1)) #i++ um index zu finden
                
                spaceLeftCheck=true #wenn mindestens ein passender buddy dabei ist, wird dieser boolean auf true gesetzt, wenn nicht bleibt er false und das programm gibt dem user in der else ganz unten zurück, dass nicht genug speicher vorhanden ist
            
            fi
        done

        if [ $spaceLeftCheck = true ] #wenn ein buddy groß genug für den task war, kann er zugewiesen werden 
        then
            #echo "wtf"
            if [ "$task" -gt "$half" ] #task ist größer als die hälfte des buddys, dh er passt in kein kleineres
            then 
                echo "task -gt half = task ist größer als die hälfte des buddys -> passt direkt rein"
                tasklist+=("$sizeCheck") #der buddy wird in die TASKLISTE gesetzt, es wird sizecheck benutzt, da diese variable den passenden leeren buddy aus der for loop darüber hat
                echo -e "\e[32mTask $task erfolgreich allocated - benötigte $sizeCheck Speicher\e[0m"
                
                #buddylist=( "${buddylist[@]/$elemFromForLoop}" )
                #echo "indexDelete $indexForDelete"
                echo "removing ${buddylist[$indexForDelete]} from buddylist, gets allocated or splitted"
                unset buddylist["$indexForDelete"] #es wird der buddy aus der buddylist gelöscht, da er 4 zeilen darüber als nun aktiver task in die tasklist gesetzt wurde
                local cloneList=("${buddylist[@]}") #clon zeugs, bin noch nicht sicher ob man es noch braucht, hat davor bei unset "null" geschrieben statt zu löschen
                buddylist=("${cloneList[@]}") #diese zeile + zeile darüber wahrscheinlich obsolete
                
                
            
            elif [ "$task" -le "$half" ] #task ist kleiner oder gleich der hälfte des buddys, also muss noch ein oder mehrmals halbiert werden, um den kleinst möglichen buddy zu finden in den der task passt
            then
               
                
                echo "task -le half = task ist kleiner(gleich) als hälfte des buddys -> buddy muss noch einmal oder mehrmals halbiert werden"
                #echo "indexDelete $indexForDelete"
                echo "removing ${buddylist[$indexForDelete]} from buddylist, gets allocated or splitted"
                unset buddylist["$indexForDelete"] #der task wird aus der buddyliste gelöscht, da er nun benutzt wird
                local cloneList=("${buddylist[@]}") #idk
                buddylist=("${cloneList[@]}") #idk
                
                while [ "$task" -le "$half" ] #hier wird wieder so lange geteilt, bis der kleinst mögliche buddy gefunden wurde, jede Teilung wird als leerer Buddy in die buddyliste geschrieben
                                                #wieder so lange bis der task größer als die halbierung ist (muss am ende verdoppelt werden, s. 10 Zeilen unten)
                do
                    #echo "half $half"
                    buddylist+=("$half") #jede teilung kommt in buddylist
                    half=$(("$half"/2)) #wird so lange geteilt bis passt
                    
                    
                    #echo "half added to buddylist: $half"
                done
                # local lang="${#buddylist[@]}"
                # lang=$(("$lang"-1))
                #unset buddylist["$lang"]
                #local cloneList=("${buddylist[@]}")
                #buddylist=("${cloneList[@]}")
                #echo "remove from buddylist: $half"
                local memToAdd=$(("$half"*2)) #am ende doppelte der hälfte in task liste adden, da buddy verkleinert wurde bis task größer als der buddy ist - aber man braucht einen buddy der größer als der task ist, sodass der task rein passt
                tasklist+=("$memToAdd") #wird nun als aktiver task in die tasklist geaddet
                echo -e "\e[32mTask $task erfolgreich allocated - benötigte $memToAdd Speicher\e[0m"
                # echo "add to tasklist: $memToAdd"

            else
                echo "SOLLTE NICHT VORKOMMEN"       
            fi
        else #else case zu spaceLeftCheck, wenn kein buddy mit genug platz mehr frei ist, bekommt der user die meldung, dass er nicht zugewiesen worden konnte
            echo -e "\e[31mTask $task ist zu groß - konnte nicht zugewiesen werden\e[0m"
        fi
    else #wenn buddylist leer und taskliste voll
        echo -e "\e[31mTask $task konnte nicht zugewiesen werden - der komplette Speicher ist belegt\e[0m"
    
    fi

}

function deallocate() {
    
    index=$1
    tasklistLen="${#tasklist[@]}"
    echo "tasklistLen $tasklistLen"

    if [[ "$index" -gt "$tasklistLen" ]]
    then
        echo -e "\e[31mDieser Task existiert nicht\e[0m"

    elif [[ "$index" -le 0 ]]   
    then
        echo -e "\e[31mNicht möglich - Tasks fangen bei 1 an\e[0m"

    else

        index=$(("$1"-1))
        buddyThatHasToGoBackInBuddylist="${tasklist["$index"]}"
        buddylist+=("$buddyThatHasToGoBackInBuddylist")
        buddyIDThatHasToGoBack=${taskidlist["$index"]}
        buddyidlist+=("$buddyIDThatHasToGoBack")
        echo "buddyID that goes back: $buddyIDThatHasToGoBack"
        
        unset tasklist["$index"]
        taskCloneList=("${tasklist[@]}")
        tasklist=("${taskCloneList[@]}")

        unset taskidlist["$index"]
        taskIdCloneList=("${taskidlist[@]}")
        taskidlist=("${taskIdCloneList[@]}")
        mergeBuddys
    fi

    

}

function mergeBuddys() {

    local save=0
    local indx=0
    buddyidlist+=(8) #testing
    buddylist+=(32) #testing
    for ele in "${buddyidlist[@]}"
    do
        for elem in "${buddyidlist[@]}"
        do  
            echo "ele $ele"
            echo "elem $elem"
            echo "save $save"
        
            if [ "$ele" -eq "$elem" ]
            then


                echo "elem = save"
                echo "$elem = $save"
                echo "indx: $indx"
                
                local indxMinusOne=$(("$indx"-1))
                local saveBuddyId="${buddyidlist["$indx"]}"
                
                
                #buddys addieren
                local buddyOne=${buddylist["$indxMinusOne"]}
                local buddyTwo=${buddylist["$indx"]}
                
                local mergedBuddy=$(("$buddyOne"+"$buddyTwo"))


                #buddy indices aus buddyidlist löschen
                unset buddyidlist["$indx"] #index der gleichen tasks aus id liste löschen
                unset buddyidlist["$indxMinusOne"] ##index der gleichen tasks aus id liste löschen
                echo "index $indx und $indxMinusOne aus buddyidlist gelöscht"
                buddyIdCloneList=("${buddyidlist[@]}")
                buddyidlist=("${buddyIdCloneList[@]}")

                #mergen der zwei gleichen buddys
                #beide löschen
                unset buddylist["$indx"]
                unset buddylist["$indxMinusOne"]
                taskIdCloneList=("${taskidlist[@]}")
                taskidlist=("${taskIdCloneList[@]}")
                echo "index $indx und $indxMinusOne aus taskidlist gelöscht"

                #mergedBuddy wieder in buddylist einfügen
                buddylist+=("$mergedBuddy")

                #id für neuen mergedBuddy in buddyidlist eintrage
                echo "old id= $saveBuddyId"
                echo "dict = ${idAssign["$saveBuddyId"]}"
                buddyidlist+=("${idAssign["$saveBuddyId"]}")


            fi
        
            save="$elem"
            echo "indexxxx $indx"
            indx=$(("$indx"+1))
            echo "---"
        done
    done
}

#######################################

inoo=1
function testrun() {


    local task=$1
    echo $inoo
    echo "TASK: $1"
    allocate "$memory" "$task"
    echo " "
    echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
    echo -e "\e[46mBuddy ID list: ${buddyidlist[@]}\e[0m"
    echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"
    echo -e "\e[43mTask ID list: ${taskidlist[@]}\e[0m"
    for i in "${!idAssign[@]}"
        do
            echo "key  : $i"
            echo "value: ${idAssign[$i]}"
    done
    devAdd
    echo "-----------------------------------------------------------------------------------------------"
    
    inoo=$(("$inoo"+1))
}

function testrunD() {

    echo ""
    local k=$1
    echo "Task to deallocate: $k"
    deallocate "$k"
    echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
    echo -e "\e[46mBuddy ID list: ${buddyidlist[@]}\e[0m"
    echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"
    echo -e "\e[43mTask ID list: ${taskidlist[@]}\e[0m"
    echo "1 ${tasklist[0]}"
    echo "2 ${tasklist[1]}"
    echo "3 ${tasklist[2]}"
    echo "4 ${tasklist[3]}"
    devAdd

}



testrun 120
#testrun 62
# testrun 120
# testrun 30
# testrun 400
# testrun 125
testrunD 1
#testrunD 1
######################################








































#returns potenzmenge für die tasks
function allocateCalc() {
    
    local mem=$1
    local task=$2
    
    while [ "$task" -le "$mem" ] #-le da task in memory passen soll
        
        do  
           mem=$(("$mem"/2))    #teilt solange bis passt
           #buddylist+=("$mem")
           
        done
    
    mem=$(("$mem"*2)) #dann ein mal verdoppeln
    buddylist+=("$mem")
   
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

function addtobuddylist() { 
    buddylist+=("$1")

}


# checks wie viel speicher noch übrig ist (rechnet max speicher(der vom user am anfang eingegeben) - summe aller werte(tasks) in der liste)
function memleft() {
    local mem=$1 
    local potmemused=0
    for elem in "${list[@]}"  #adds all tasks up to see how much memory is used
    do 
        potmemused=$(("$potmemused"+"$elem"))
    done
    
    local memleft=$(("$mem"-"$potmemused")) #gesamt memory - summe aller tasks
    echo "$memleft"
}


# # löscht tasks aus liste
# function deallocate() {
#     local taskindx=$1 #index des tasks den man beenden will

#     if [ "$taskindx" -gt ${#list[@]} ] || [ "$taskindx" -lt 0 ] #checkt ob die eingegebene zahl überhaupt index der liste ist oder ob eingegebene zahl kleiner 0
#     then 
#         echo "Task $taskindx doesn't exist" #wenn task nicht teil der liste ist
#     else
#         local ind="$taskindx-1" #wenn task teil der liste ist wird er aus der liste gelöscht
#         unset list["$ind"] 
#         echo "Task $taskindx deallocated"
#         listClone=("${list[@]}") #unset löscht array element nicht sondern ersetzt es durch null, deshalb wird array auf ein neues kopiert, sodass null werte raus fallen
#         list=("${listClone[@]}") #list wieder zurück kopieren, da mit list gearbeitet wird
#     fi
    
# }

# checkt ob Zweierpotenz, wichtig für erste user eingabe(eingabe muss zweierpotenz sein)
function checkIfPowerOfTwo() {

    n=$1
    (( n > 0 && (n & (n - 1)) == 0 )) #von so, keine ahnung was hier returned wird?############remove###############https://unix.stackexchange.com/questions/481552/check-if-numbers-from-command-line-are-powers-of-2/481558
}

# check0=true #wichtig für while loops
# check1=true #same
# initCheck=true

###main###
# while true 
# do
#     read -p "Speicher eingeben" memoryInput #user input für speicher den programm haben soll
#     mem=$memoryInput #mem bleibt immer dieser eingegeben original wert, wird zum rechnen benutzt
#     if [[ "$memoryInput" =~ $num ]] && checkIfPowerOfTwo "$memoryInput" = true #user input muss zahl sein und muss zweierpotenz sein
#     then 
#################



# while true
# do 
#     read -p "Task (a)llocaten, Task (d)eallocate, alle (T)asks anzeigen oder (e)xit" inp #"hauptmenü", user kann hier task allocaten, deallocaten, alle aktiven tasks anzeigen oder programm verlassen
#     #check1=true
#     if [ "$inp" = "a" ] || [ "$inp" = "allocate" ]  # wenn user einen task starten will (allocate)
#     then
    
#         while true
#         do
#             read -p "Allocate Wert eingeben" allocateInput
#             if [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -gt 0 ] #input muss zahl sein und größer 0
#             then
            
#                 echo " "
             
#                 allocate "$memory" "$allocateInput"

                
#                 echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
#                 echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"   
#                 echo ""
#                 break

                
                
            
#             elif [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -le 0 ] #wenn eingabe zahl aber <= 0 bekommt user die meldung, dass es keinen sinn macht
#             then
                
#                 printf "\nKann keinen Task kleiner/gleich 0 allocaten (macht keinen sinn)\n"
#                 echo ""
#                 break

#             else
#                 printf "\nEingabewert muss eine Zahl sein\n" #wenn eingabe keine pure zahl ist 
#                 echo " "
#                 break
#             fi
#         done
#     elif [ "$inp" = "t" ] || [ "$inp" = "show tasks" ] || [ "$inp" = "tasks" ] #wenn user alle aktiven tasks anzeigen lassen will
#     then

#         echo " "
#         echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
#         echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"   

#     elif [ "$inp" = "d" ] || [ "$inp" = "deallocate" ] #wenn user einen task beenden will (deallocate)
#     then
#         read -p "Welchen Task deallocaten?" deallocInput

#         if ! [[ $deallocInput =~ $num ]] #wenn task keine zahl ist 
#         then
#             echo " "
#             echo "Eingabewert muss eine Zahl sein"
#             echo " "
#             #break
#         else

#             echo " "
#             deallocate "$deallocInput"
#             echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
#             echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"   

#         fi
#     elif [ "$inp" = "e" ] || [ "$inp" = "exit" ] #end program
#     then
#         echo "Programm beendet"
#         exit 1
#     elif [ "$inp" = "mem" ] #nur zum testen
#     then
#         echo "mem $mem"
#         memleee=$(memleft "$mem") 
#         echo "memLeft $memleee"
#         singleTaskMem=$(nextSmallerPot "$memleee") 
#         echo "max potmem: $singleTaskMem" 
#         echo "buddylist: ${buddylist[@]}"
#     else #wenn user eingabe keines der oeberen commands ist (a, d, t, e) muss er erneut erwas eingeben
#         echo "Command nicht erkannt - bitte erneut eingeben"
#     fi
# done
#################        
#     else
#         echo " "
#         echo "Eingabe muss eine Zweierpotenz sein" #else clause zu erster eingabe, wenn eingabe keine zweierpotenz ist
#         echo " "
#     fi
# done
