#! /usr/bin/bash

##################
#######fixen
#WENN MAN 1 ALLOCATED BEKOMMT DER BUDDY DIE GRÖßE 0
#####################



# Das ganze Programm besteht im Groben aus 3 großen Funktionen, sowie 4 Listen und einem Dictionary
# allocate(), deallocate() und mergeBuddys()
#
# alle funktionen werden vor der Funktion noch einmal genauer erklärt.
# allocate() wird benutzt um neue Tasks in passende buddys zu setzen. Sie errechnet den passenden buddy, setzt aktive buddys in die tasklist und nicht aktive (leere) buddys in die buddylist, vergibt buddy ids und regelt die parent id vergabe per dictionary
# deallocate() wird benutzt um Tasks, die beendet werden sollen, wieder aus der Tasklist in die Buddylist zu verschieben. deallocate() ruft immer die mergeBuddys() funktion auf.
# mergeBuddys() wird benutzt um leere Buddys in der Buddylist wieder zu ihrem Vaterbuddy zusammen zu fügen.
#  
# In dem Array tasklist werden aktive Tasks (also gefüllte Buddys) gespeichert
# In dem Array buddylist werden nicht aktive buddys (leere buddys) gespeichert 
# In dem Array buddyidlist werden die ids zu jedem leeren buddy gespeichert -> z.B. buddylist[2] hat id: buddyidlist[2] - es können immer nur 2 buddys die gleiche id haben
# In dem Array taskidlist werden die ids zu jedem befüllten buddy gespeichert -> z.B. tasklist[2] hat id: taskidlist[2] - es können immer nur 2 buddys die gleiche id haben
# In dem dictionary idAssign werden ids und dazu ihre Parent IDs gespeichert -> z.B. buddys mit der id 2 -> haben parent id 1 -> wenn also die beiden buddys mit der id 2 wieder gemerged werden, hat ihr vaterbuddy die id 1


#unwichtig
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


#memory=1024

re='[a-zA-Z]'
num='[0-9]' #wird für user input benutzt (checkt ob eingabe eine Zahl ist)

tasklist=() #liste für aktive tasks (befüllte buddys)
buddylist=() #liste für leere buddys
taskidlist=() #liste für die id der aktiven buddys
buddyidlist=() #liste für id der leeren buddys
declare -A idAssign #dictionary für id->vater id

idCount=1 #wichtig, regelt id zuweisungen und vater ids






###functions###



# Allocate Function
# Die allocate Funktion besteht aus 2 Teilen
# Teil 1 läuft, wenn noch kein Buddy vergeben wurde (Bei Programmstart oder wenn im laufenden Programm alle Tasks beendet sind)
# Sobald eine allocation durchgeführt wurde, wird Teil 2 benutzt.
# Teil 2 durchläuft dann die buddylist(leere Buddys) und sucht nach dem kleinstmöglichst passenden buddy.
# Wenn direkt ein richtiger buddy gefunden wurde (z.B. Task 30, Buddy 32), wird der Buddy (32) aus der buddylist gelöscht und in die tasklist gesetzt. Die Id wird aus der buddyidlist gelöscht und in die taskidlist gesetzt. (einfacher Fall)
# Wenn kein passender buddy in den leeren buddys gefunden werden kann muss ein buddy geteilt werden (z.B. Task 30, Buddy 64 -> man will aber buddy 32 haben). Auch hier wird aber wieder das kleinstmögliche passende gesucht (task=30 und buddylist=(256, 64, 16) --> 64 wird genommen und geteilt bis passt)
# In diesem Fall müssen auch wieder neue ids an die neu geteilten buddys vergeben werden. Bei jedem Teilvorgang wird die eine Hälfte der Teilung in die buddylist (als leeres Buddy) geschrieben, bekommt dazu eine neue id in die buddyidlist und einen Eintrag in das idAssign dictionary mit Verweis auf den zuvor geteilten Buddy (64 wird geteilt in 32 32 - das erste 32 wird direkt in die buddylist geschrieben, das andere wird weiter benutzt (geteilt oder zugewiesen), beide bekommen als parent id die 64)
# 




function allocate() {


    local mem=$1    #speicher der vom nutzer eingegeben wurde
    local task=$2   #task der nun allocated werden soll
    local sizeCheck=$(("$mem"+1)) #
    local i=0 #zählvariable
    local spaceLeftCheck=false #boolean der später benutzt wird

    echo -e "\e[42mALLOCATE Task $task\e[0m"
  

    if [ "${#buddylist[@]}" -eq 0 ] && [ "${#tasklist[@]}" -eq 0 ] #wenn die liste leer ist wird dieses verfahren benutzt (check ob buddylist und tasklist leer ist)
    then

        if [ "$task" -le "$mem" ] #wenn der task < speicher
        then 
            while [ "$task" -le "$mem" ] #-le da task in memory passen soll; solange der Task <= dem Speicher -> wird der Speicher geteilt, bis der Speicher kleiner ist -> dann speicher einmal verdoppelt (task passt nun perfekt in den Zweierpotenz buddy)
                
                do  
                mem=$(("$mem"/2))    #teilt solange bis passt
                if [ "$mem" -ge "$task" ] #solange der task noch kleiner als gesammt mem ist wird jede halbierung als leerer buddy in die buddylist geschrieben
                then
                    
                    buddylist+=("$mem") #leere buddys kommen in liste

                    buddyidlist+=("$idCount") #jede Teilung, also jeder buddy, bekommt seine id in der buddyidlist
                    
                    #dictionary für spätere rückwärtszuweisung
                    idCountMinusOne=$(("$idCount"-1)) 
                    idAssign["$idCount"]="$idCountMinusOne" #buddys mit id 3 bekommen (3-1=2) als "vaterid" in dictionary geschrieben
                    
                   
                    
                    idCount=$(("$idCount"+1)) #idCount hochzählen
                    #echo "idCount = $idCount"
                fi       
                done
            
            mem=$(("$mem"*2)) #dann ein mal verdoppeln, da so lange geteilt wurde, bis mem<task, man will aber dass task noch in mem passt
            
            tasklist+=("$mem") #aktiver task kommt in die taskliste (hier mit mem gerechnet)

            echo -e "\e[32mTask $task erfolgreich allocated - benötigte $mem Speicher\e[0m"

            idCountMinusOne=$(("$idCount"-1))
            taskidlist+=("$idCountMinusOne") #task bekommt id seines "buddys", da aber oben schon einmal hoch gezählt wurde, muss task jetzt count-1 bekommen

        else #wenn der Task > Speicher (von User festgelegt), bekommt user die meldung, dass Task zu groß für den Speicher ist

            echo -e "e[31mTask $task ist zu groß, nicht genug speicher verfügbar\e[0m"

        fi


    elif [ "${#buddylist[@]}" -gt 0 ] #sobald die erste allocation durchgeführt wurde, wird ab dann diese methode benutzt (buddylist > 0)
    then
        #echo "else case"
        #FORLOOP
       
       
        for elem in "${buddylist[@]}" #hier wird die buddyliste(mit leeren buddys) durchlaufen, und nach dem kleinst möglichen buddy gesucht in den der task passt,
            #indem zum einen geschaut wird ob ein buddy größer(gleich) dem angeforderten task ist UND ob ein buddy kleiner als der buddy vor ihm in der liste ist
            #DIE BUDDYS WERDEN NACHEINANDER DURCHLAUFEN UND ÜBERSCHREIBEN $sizeCheck SO LANGE BIS DER KLEINSTE BUDDY PASST (oder einer der kleinsten wenn es mehrere gibt (-le))
        do 
            
            if [ "$elem" -ge "$task" ] && [ "$elem" -le "$sizeCheck" ] # wenn task kleiner als elembuddy(aktueller buddy der for loop) und elembuddy kleiner als der buddy vorher in der liste [?< oder <= sollte egal sein?]
            then   
                sizeCheck=$elem #wird benutzt um zu prüfen, dass bei Durchlaufen durch Liste ein kleines und passender buddy nicht durch einen größeren passenden buddy überschrieben wird (man will den kleinst möglichen buddy finden der von der größe her passt)
                
                local half=$(("$elem"/2)) #buddy wird halbiert, im nächsten if wird damit weiter gearbeitet
                #echo "half $half"
                
                local indexForDelete=$i #index des elembuddys aufheben
                
                
                spaceLeftCheck=true #wenn mindestens ein passender buddy dabei ist, wird dieser boolean auf true gesetzt, wenn nicht bleibt er false und das programm gibt dem user in der else ganz unten zurück, dass nicht genug speicher vorhanden ist
                #echo "if triggered bei: $elem"
            fi
            i=$(("$i"+1)) #i++ um index zu finden
            #echo "i $i"
            #echo "indexForDelete $indexForDelete"
            #echo "elem $elem"
        done


        

        if [ $spaceLeftCheck = true ] #wenn ein buddy groß genug für den task war, kann er zugewiesen werden, dh es wurde eine möglichkeit gefunden den task in die verfügbaren buddys zu allocaten

        then


            # diese if else ist der letzte große teil der allocate function. Es gibt den Fall, dass der Task direkt in den kleinst möglichen buddy passt (30 in 32), und den anderen Fall, dass der kleinst mögliche buddy noch ein oder mehrmals geteilt werden muss (11 in 32)

            if [ "$task" -gt "$half" ] #task ist größer als die halbierung des buddys, dh er passt direkt in diesen buddy, und man muss den buddy nicht weiter halbieren
            then 
                
                tasklist+=("$sizeCheck") #der buddy wird in die TASKLISTE gesetzt, es wird sizecheck benutzt, da diese variable den passenden leeren buddy aus der for loop darüber hat
                taskidlist+=("${buddyidlist["$indexForDelete"]}") #entsprechende id aus buddyidlist in taskidlist kopieren, indexForDelete wurde in der loop darüber gespeichert, ist also der index des passenden buddys
                echo -e "\e[32mTask $task erfolgreich allocated - benötigte $sizeCheck Speicher\e[0m"
    
                
                #taskidlist+=("$idCount") #task bekommt id seines "buddys", da aber oben schon einmal hoch gezählt wurde, muss task jetzt count-1 bekommen
                
                #buddylist=( "${buddylist[@]/$elemFromForLoop}" )
                #echo "indexDelete $indexForDelete"
              

                #task aus buddylist löschen, da er oben drüber in tasklist gesetzt wurde
               
                unset buddylist["$indexForDelete"] #es wird der buddy aus der buddylist gelöscht, da er 4 zeilen darüber als nun aktiver task in die tasklist gesetzt wurde; man benutzt wieder indexForDelete, da die indices in allen listen parallel sind
                local cloneList=("${buddylist[@]}") #clone zeugs, bin noch nicht sicher ob man es noch braucht, hat davor bei unset "null" geschrieben statt zu löschen
                buddylist=("${cloneList[@]}") #diese zeile + zeile darüber wahrscheinlich obsolete
                
                

                #id aus buddyidlist löschen, das er oben drüber in taskidlist gesetzt wurde
                
                unset buddyidlist["$indexForDelete"] #id wird aus der buddyIDlist gelöscht, da die id nun in taskidlist ist
                local cloneIdList=("${buddyidlist[@]}") #clone
                buddyidlist=("${cloneIdList[@]}") 
                
            
            #das ist nun der andere(kompliziertere) fall, wenn der buddy noch ein oder mehrmals geteilt werden muss, bis der task perfekt hinein passt

            elif [ "$task" -le "$half" ] #task ist kleiner oder gleich der hälfte des buddys, also muss noch ein oder mehrmals halbiert werden, um den kleinst möglichen buddy zu finden in den der task passt
            then
               
                #echo "half $half"
                
                #echo "indexForDelete $indexForDelete"



                #buddy aus buddylist löschen, da er nun aufgeteilt wird
                
                unset buddylist["$indexForDelete"] #der task wird aus der buddyliste gelöscht, da er nun benutzt wird
                local cloneList=("${buddylist[@]}") #clone
                buddylist=("${cloneList[@]}") #clone


               
                #buddy ID aus buddyIDlist löschen, da dieser task erstmal nicht mehr existiert

                local saveIndexOfDeletedBuddy="${buddyidlist[$indexForDelete]}" #id saven, da sie vielleicht wieder ins dictionary als parent id geschrieben wird
                
                unset buddyidlist["$indexForDelete"] #buddy ID aus buddyIDlist löschen
                local cloneIdList=("${buddyidlist[@]}") #clone
                buddyidlist=("${cloneIdList[@]}") #clone
                
                loopCount=0 #wird weiter unten benötigt um mit zu zählen wie oft die loop läuft, wichtig für if unten; wird hier nur auf 0 gesetzt, wichtig, dass es immer wieder auf 0 gesetzt wird


                #weiß nicht mehr ob das noch benutzt wird, glaube nicht
                local doubleHalf=$(("$half"/2)) #wenn buddy für den task nur noch einmal geteilt werden muss (also größer als die hälfte der aktuellen hälfte ist), dann wird etwas anderes ins dictionary geschrieben, deshlab hier der check
                local halfCheck=false


                #####
                # if [ "$task" -gt "$doubleHalf" ]
                # then 
                #     halfCheck=true

                # fi



                #nun muss wieder geteilt werden bis der task perfekt in den buddy passt (ähnliches Verfahren wie am Anfang dieser Funktion)
                while [ "$task" -le "$half" ] #hier wird wieder so lange geteilt, bis der kleinst mögliche buddy gefunden wurde, jede Teilung wird als leerer Buddy in die buddyliste geschrieben
                                                #wieder so lange bis der task größer als die halbierung ist (muss am ende verdoppelt werden, s. 10 Zeilen unten)
                do
                    
                    


                    buddylist+=("$half") #jede teilung kommt in buddylist als leerer Buddy, mit der anderen Hälfte wird weiter gearbeitet (geteilt oder allocated)
                    buddyidlist+=("$idCount") #neuer buddy bekommt neue ID durch hochzählen von idCount


                    #####
                    #local saveIdForTaskIdList="$idCount"

                    #dictionary weiter schreiben
                    idCountMinusOne=$(("$idCount"-1)) #ID mit zugehöriger parent ID wird wieder ins dict geschrieben (ähnlich wie oben)



##################################################################################################################################################################
                    #dieser teil ist extrem wichtig. Bei der ersten Teilung muss der neue buddy die Parent ID vom buddy bekommen aus dem er geteilt wurde (wird ins dict geschrieben),
                    #wenn danach weiter geteilt wird, wird wieder id und parent id über idCount und idCountMinusOne geregelt

                    #"$halfCheck" = true 
                    if [ "$loopCount" -eq 0 ] #loopCount ist 0 beim ersten durchlauf der schleife
                    
                    then
                    
                    idAssign["$idCount"]="$saveIndexOfDeletedBuddy" #wenn loopcount 0 ist, heißt das, dass nur einmal geteilt werden musste, also bekommt der geteilte buddy die parent id des buddys davor (der buddy der ein bisschen weiter oben aus der buddylist gelöscht wurde) ins dictionary geschrieben (z.B. 8->2 statt 8->7)
                    
            
                    else
    
                    idAssign["$idCount"]="$idCountMinusOne" #wenn loopcount > 0, heißt das, es musste mehr als einmal geteilt werden, also bekommt die der buddy ab jetzt die parent id der gerade vorherigen Teilung (teilung in dieser schleife)
                  

                    fi
##################################################################################################################################################################
                    

                    idCount=$(("$idCount"+1)) #idCount hochzählen
                    #echo "idCount = $idCount"


                    #echo "half $half"
                    
                    half=$(("$half"/2)) #buddys werden wieder so lange geteilt bis passt
                    #echo "half after half $half"

                    loopCount=$(("$loopCount"+1)) #loopcount hoch zählen
                    
                    #echo "half added to buddylist: $half"
                done

                # local lang="${#buddylist[@]}"
                # lang=$(("$lang"-1))
                #unset buddylist["$lang"]
                #local cloneList=("${buddylist[@]}")
                #buddylist=("${cloneList[@]}")
                #echo "remove from buddylist: $half"


                local memToAdd=$(("$half"*2)) #am ende doppelte der hälfte in task liste adden, da buddy verkleinert wurde bis task größer als der buddy ist (mathematisch so gelöst) - aber der buddy muss ja größer als der task sein
                tasklist+=("$memToAdd") #wird nun als aktiver task in die tasklist geaddet

                idCountMinusOne=$(("$idCount"-1))
                taskidlist+=("$idCountMinusOne") #task bekommt entsprechende id, man muss 1 abziehen, da der count aus der schleife 1 zu hoch ist (da geteilt wird bis buddy kleiner gleich task, aber man will ja den verdoppelten, siehe 3 zeilen weiter oben memToAdd=half*2)
                echo -e "\e[32mTask $task erfolgreich allocated - benötigte $memToAdd Speicher\e[0m"
            
                # echo "add to tasklist: $memToAdd"

            else
                echo -e "\e[31mSOLLTE NICHT VORKOMMEN\e[0m"       
            fi
        else #else case zu spaceLeftCheck, wenn kein buddy mit genug platz mehr frei ist, bekommt der user die meldung, dass er nicht zugewiesen worden konnte
            echo -e "\e[31mTask $task ist zu groß - konnte nicht zugewiesen werden\e[0m"
        fi
    else #wenn buddylist leer und taskliste voll
        echo -e "\e[31mTask $task konnte nicht zugewiesen werden - der komplette Speicher ist belegt\e[0m"
    
    fi

}




# Dies ist nun die Funktion um Tasks zu beenden.
# Wen nein Task beendet wird, wird er aus der tasklist gelöscht und in die buddylist eingeügt (als nun leerer buddy). Analog dazu wird seine id aus der taskidlist in die buddyidlist verschoben.
function deallocate() {
    


    echo -e "\e[41mDEALLOCATE\e[0m"



    index=$1 #input der function. Welcher Task soll deallocated werden. User gibt hier eine Zahl ein. 1 heißt erster Task der tasklist wird deallocated (wenn es ihn gibt)
    #bash arrays starten bei 0 aber der user gibt "normale" Indexangabe an, also muss später index-1 gerrechnet werden um den richtigen buddy zu löschen

    tasklistLen="${#tasklist[@]}" #länge der tasklist
    

    if [[ "$index" -gt "$tasklistLen" ]] #wenn der input des users größer ist als elemente(tasks) in der liste, bekommt er die meldung, dass es diesen task nicht gibt (liste ist nur 4 lang, er will task 5 deallocaten -> geht nicht)
    then
        echo -e "\e[31mDieser Task existiert nicht\e[0m"

    elif [[ "$index" -le 0 ]]   #wenn user negative zahlen oder 0 eingibt, geht auch nicht
    then
        echo -e "\e[31mNicht möglich - Tasks fangen bei 1 an\e[0m"

    
    #wenn beide ifs nicht erfüllt sind, heißt es es ist ein task der in der liste ist
    else 

        index=$(("$1"-1)) #1 von index abziehen um richtigen array index zu bekommen

        buddyThatHasToGoBackInBuddylist="${tasklist["$index"]}" #den buddy saven der gelöscht wird (kein index sondern wirklicher zweierpotenz buddy, wird später auch für dict benötigt)
        buddylist+=("$buddyThatHasToGoBackInBuddylist") #buddy aus tasklist in buddylist kopieren


        buddyIDThatHasToGoBack=${taskidlist["$index"]} #buddy id des zu löschenden buddys
        buddyidlist+=("$buddyIDThatHasToGoBack") #buddy ID aus taskIDlist in buddyIDlist kopieren

        #task aus tasklist löschen
        unset tasklist["$index"]
        taskCloneList=("${tasklist[@]}")
        tasklist=("${taskCloneList[@]}")

        #task ID aus taskIDlist löschen
        unset taskidlist["$index"]
        taskIdCloneList=("${taskidlist[@]}")
        taskidlist=("${taskIdCloneList[@]}")

        #user mitteilen, dass buddy deallocated wurde
        local printIndex=$(("$index"+1)) #wird von arrayindex in menschen index gerechnet
        echo -e "\e[32mTask $printIndex deallocated\e[0m"

        #nun ist der deallocate prozess vorbei(task und id wurden aus listen gelöscht und als leerer buddy in buddylist und seine id in buddyIDlist geschrieben)
        #hier beginnt der merge prozess: wenn zwei geschwisterbuddys in der buddylist sind werden sie zu ihren Parent Buddy gemerged

       
       
        local mergeLength=${#buddylist[@]} #wie viele tasks sind in buddylist = wie viel buddys könnten gemerged werden



        for (( c=1; c<="$mergeLength"; c++ )) #mergeBuddys function wird so oft gecallt wie buddys in der liste sind #####(-1 reicht wahrscheinlich)
        do
            mergeBuddys #function wird gecallt
            
        done
       

        #dictionary zurücksetzen, wenn keine tasks mehr laufen, nicht wirklich wichtig, resettet die "id -> parent id" vergabe im dictionary
        mergeLengthBuddy=${#buddylist[@]} #länge der buddylist in variable zuweisen
        mergeLengthTask=${#tasklist[@]} #länge der tasklist in variable zuweisen

        if [ "$mergeLengthBuddy" -eq 1 ] && [ "$mergeLengthTask" -eq 0 ] #wenn buddylist 1 lang ist und tasklist 0 lang ist wird dict gecleared
        then
            echo -e "\e[41mCLEARING DICTIONARY\e[0m"
            unset idAssign[@] #dictionary löschen
            idCount=1 #idcount zurücksetzen, WICHTIG
        fi
        
    fi

    

}




#Dies ist nun die Funktion die benutzt wird um gleiche Buddy wieder zu ihrem Parent Buddy zu verschmelzen
#Nur buddys die davor auch geteilt wurden können wieder zu einem werden
function mergeBuddys() {

    printList #printed einmal alle 4 listen für den user, so sieht man was im programm passiert
    echo -e "\e[45mMERGING...\e[0m"
    

    local breakCheck=false #um loops zu brechen
    local indx=0 #index der ids in buddyidlist, hiermit wird der "richtige" buddy gelöscht/bearbeitet
    local eleCount=0 #count der äußeren loop
    local elemCount=0 #count für die innere loop
   


    #hier wird nun jedes element der buddyIDlist mit jedem element verglichen, dafür werden zwei for loops benutzt
    for ele in "${buddyidlist[@]}"
    do

        if [ "$breakCheck" = true ] #um loop zu beenden, wenn ein buddy zum mergen gefunden wurde
        then
            break
        fi

        indx=0 #muss bei jeder neuen ele loop (äußere loop) wieder auf 0
        elemCount=0 #muss bei jeder neuen ele loop (äußere loop) wieder auf 0
        
        for elem in "${buddyidlist[@]}" #innere loop
        do  

           
        
            if [ "$ele" -eq "$elem" ] && [ "$eleCount" -ne "$elemCount" ] #wenn die ids sich gleichen, aber es nicht die selben in der liste sind (da kein buddy mit sich selbst mergen darf!)
            then


                if [ "$breakCheck" = true ] #um loop zu beenden, wenn ein buddy zum mergen gefunden wurde
                then
                    break
                fi
                #echo -e "\e[32mMATCH!\e[0m"

                
                
                ####
                #local indxMinusOne=$(("$indx"-1))
                local saveBuddyId="${buddyidlist["$eleCount"]}" #id saven für idAssign später, kann entwerder eleCount oder elemCount saven, ist egal, sind gleich
              
                #buddys addieren
                
                local buddyOne=${buddylist["$eleCount"]} #buddy 1
                local buddyTwo=${buddylist["$elemCount"]} #buddy 2
                

                local mergedBuddy=$(("$buddyOne"+"$buddyTwo")) #buddys werden zu parent buddy addiert
                #muss man hier schon rechnen, da später gelöscht


                #buddy indices aus buddyidlist löschen
                #index der gleichen tasks aus id liste löschen
                unset buddyidlist["$eleCount"] #id des einen siblings löschen
                unset buddyidlist["$elemCount"] #id des anderen siblings löschen
              
                buddyIdCloneList=("${buddyidlist[@]}") #clone
                buddyidlist=("${buddyIdCloneList[@]}") #clone



                #MERGEN DER ZWEI BUDDYS
                #beide löschen aus buddylist
                unset buddylist["$eleCount"]
                unset buddylist["$elemCount"]
                buddyCloneList=("${buddylist[@]}") #clone
                buddylist=("${buddyCloneList[@]}") #clone
               
                #mergedBuddy wieder in buddylist einfügen
                buddylist+=("$mergedBuddy")
             
                #id für neuen mergedBuddy in buddyidlist eintragen
                buddyidlist+=("${idAssign["$saveBuddyId"]}") #zugehörige id aus dict in idlist schreiben. (z.B. saveBuddyId=8 ---> idAssign[8]=2 ===> der mergedBuddy bekommt id 2 (DIE DIE ER AUCH BEVOR ER GETEILT WURDE HATTE))
             

                breakCheck=true #um loop zu beenden, wenn ein buddy zum mergen gefunden wurde
              
                break 

            
                
            fi
        
           
            

            indx=$(("$indx"+1)) #count up indx
            elemCount=$(("$elemCount"+1)) #count up elem loop (innerer Count)
            
        done
        eleCount=$(("$eleCount"+1)) #count up ele loop (äußerer Count)
    done
}

###############testzeugs########################
inoo=1
function testrun() {


    local task=$1
    echo $inoo
    echo "TASK: $1"
    allocate "$memory" "$task"
    echo " "
    printList
    
    devAdd
    echo "-----------------------------------------------------------------------------------------------"
    
    inoo=$(("$inoo"+1))
}

function testrunD() {

    echo ""
    local k=$1
    echo -e "\e[45mTask to deallocate: $k\e[0m"
    deallocate "$k"
    printList
   
    devAdd

}
##########################################



# function printed einfach alle listen, so sieht user was im programm passiert
function printList() {
    echo "---------"
    echo -e "\e[36mbuddylists: ${buddylist[@]}\e[0m"
    echo -e "\e[36mBuddy ID list: ${buddyidlist[@]}\e[0m"
    echo -e "\e[33mtasklist: ${tasklist[@]}\e[0m"
    echo -e "\e[33mTask ID list: ${taskidlist[@]}\e[0m"
    echo "idCount $idCount"
    echo "---------"
}







# checkt ob Zweierpotenz, wichtig für erste user eingabe(eingabe muss zweierpotenz sein)
function checkIfPowerOfTwo() {

    n=$1
    (( n > 0 && (n & (n - 1)) == 0 )) #von so, noch keine ahnung was hier returned wird?############remove###############https://unix.stackexchange.com/questions/481552/check-if-numbers-from-command-line-are-powers-of-2/481558
}




###main###


#Diese while Schleifen sind das menu für den user
while true 
do
    read -p "Speicher eingeben" memoryInput #user input für speicher den programm haben soll
    mem=$memoryInput #mem bleibt immer dieser eingegeben original wert, wird zum rechnen benutzt
    if [[ "$memoryInput" =~ $num ]] && checkIfPowerOfTwo "$memoryInput" = true #user input muss zahl sein und muss zweierpotenz sein
    then 
# ################



    while true
    do 
        read -p "Task (a)llocaten, Task (d)eallocate, (I)nformationen anzeigen, (Z)uweisungstabelle anzeigen oder (e)xit" inp #"hauptmenü", user kann hier task allocaten, deallocaten, alle aktiven tasks anzeigen oder programm verlassen
        #check1=true
        if [ "$inp" = "a" ] || [ "$inp" = "allocate" ]  # wenn user einen task starten will (allocate)
        then
        
            while true
            do
                read -p "Allocate Wert eingeben" allocateInput
                if [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -gt 0 ] #input muss zahl sein und größer 0
                then
                
                    echo " "
                
                    allocate "$mem" "$allocateInput"

                    
                    echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
                    echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"   
                    echo ""
                    break

                    
                    
                
                elif [[ "$allocateInput" =~ $num ]] && [ "$allocateInput" -le 0 ] #wenn eingabe zahl aber <= 0 bekommt user die meldung, dass es keinen sinn macht
                then
                    
                    echo ""
                    echo -e "\e[31mKann keinen Task kleiner/gleich 0 allocaten (macht keinen sinn)\e[0m"
                    echo ""
                    break

                else
                    echo ""
                    echo -e "\e[31mEingabewert muss eine Zahl sein\e[0m" #wenn eingabe keine pure zahl ist 
                    echo " "
                    break
                fi
            done
        elif [ "$inp" = "i" ] || [ "$inp" = "I" ] || [ "$inp" = "info" ] #wenn user alle aktiven tasks anzeigen lassen will
        then

            echo " "
            echo -e "\e[36mbuddy list: ${buddylist[@]}\e[0m"
            echo -e "\e[36mbuddy ID list: ${buddyidlist[@]}\e[0m"
            echo -e "\e[33mtask list: ${tasklist[@]}\e[0m"   
            echo -e "\e[33mtask ID list: ${taskidlist[@]}\e[0m"   
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

                echo " "
                deallocate "$deallocInput"
                echo -e "\e[36mLeere Buddys: ${buddylist[@]}\e[0m"
                echo -e "\e[33mBelegte Buddys: ${tasklist[@]}\e[0m"   

            fi
        elif [ "$inp" = "e" ] || [ "$inp" = "exit" ] #end program
        then
            echo "Programm beendet"
            exit 1
        elif [ "$inp" = "mem" ] #nur zum testen
        then
            echo "mem $mem"
            memleee=$(memleft "$mem") 
            echo "memLeft $memleee"
            singleTaskMem=$(nextSmallerPot "$memleee") 
            echo "max potmem: $singleTaskMem" 
            echo "buddylist: ${buddylist[@]}"

        elif [ "$inp" = "dict" ] || [ "$inp" = "z" ] || [ "$inp" = "Z" ]
        then
            echo ""
            echo -e "\e[45mDictionary\e[0m"
            for i in "${!idAssign[@]}"
            do
                echo "Buddy-ID:  $i"
                echo "Parent-ID: ${idAssign[$i]}"
                echo ""
            done

        else #wenn user eingabe keines der oeberen commands ist (a, d, t, e) muss er erneut erwas eingeben
            echo "Command nicht erkannt - bitte erneut eingeben"
        fi
    done
################        
    else
        echo " "
        echo -e "\e[31mEingabe muss eine Zweierpotenz sein\e[0m" #else clause zu erster eingabe, wenn eingabe keine zweierpotenz ist
        echo " "
    fi
done
