#!/bin/bash

#Created by Jacob Sortors and Bohdan Ivchenko


#Calls initial dialog menu
select=`dialog --menu "Welcome to the calender. Please choose one:" 12 50 4 1 "Create an appointment" 2 "Review current appointments" 3 "Display all appointments" 4 "Edit an existing appointment" --output-fd 1`

function create_an_appointment(){
    SelectDate=`dialog --nocancel --calendar "Select a date" 0 0 --output-fd 1` # if user clicks cancel, then we get an error, so I just removed a cancell button
    Time=`dialog --nocancel --timebox "Event time" 0 50 --output-fd 1`
    EndTime=`dialog --timebox "Event end time" 0 0 --output-fd 1`
    Description=`dialog --no-cancel --inputbox "Event description" 0 40 --output-fd 1`
    dialog --msgbox "Event created. \n Date: $SelectDate \n Time: $Time \n End time: $EndTime \n $Description" 0 0 
    
    echo "$SelectDate $Time $EndTime $Description" >> /tmp/calendars/Bcalendar
   
}



	function review_appointments(){
    
    #This section creates a dialog string to run. It makes a list based on the save file
    file=`wc -l < /tmp/calendars/Bcalendar`
    
    #This section checks if the appointment list is empty
    if [ $file -eq 0 ]
    then
        dialog --msgbox "You do not currently have any appointments" 0 0
    else
        
        i=1
        #reference TEMPSTRING. Can be deleted when not needed
        #TEMPSTRING='dialog --checklist "Choose the options you want:" 0 0 0  1 cheese on 2 "Mustard" on  3 anchovies off'
        TEMPSTRING='dialog --checklist "View and delete appointments" 0 0 '
        
        TEMPSTRING="$TEMPSTRING$file"



        

        while [ $file -ge $i ]
        do
            LINEGET=`sed -n "$i"p /tmp/calendars/Bcalendar`

            TEMPSTRING="$TEMPSTRING $i '$LINEGET' off"
            #
            #This prints the contents of a line without dialog. Use it as reference.
            #echo `sed -n "$i"p /tmp/calendars/Bcalendar`
            
            i=$((i+1))
            
        done
        
        TEMPSTRING="$TEMPSTRING --output-fd 1"
        
        SelectedDates=`eval $TEMPSTRING` #evaluates created dialog as if you typed it into command line
        


        SelectedDates=${SelectedDates// /d;}
        
        echo $SelectedDates
        
        if [ ! -z $SelectedDates ]
        then
            sed -i "$SelectedDates"d /tmp/calendars/Bcalendar
            dialog --msgbox "Selected dates have been deleted" 0 0
        fi
        

    fi
}



function edit_appointments() {
    


     #This section creates a dialog string to run. It makes a list based on the save file
    file=`wc -l < /tmp/calendars/Bcalendar`
  
    #This section checks if the appointment list is empty
    if [ $file -eq 0 ]
    then
        dialog --msgbox "You do not currently have any appointments" 0 0
    else
        
        i=1


        TEMPSTRING='dialog --menu "View and edit appointments" 0 0 '
        
        TEMPSTRING="$TEMPSTRING$file"
        
 
       #eval $TEMPSTRING #evaluates created dialog as if you typed it into command line
        
 
        while [ $file -ge $i ]
        do
            LINEGET=`sed -n "$i"p /tmp/calendars/Bcalendar`
            TEMPSTRING="$TEMPSTRING $i '$LINEGET'"

            
            #This prints the contents of a line without dialog. Use it as reference.
            #echo `sed -n "$i"p TestDelete`
            
            i=$((i+1))
            
        done
        
        TEMPSTRING="$TEMPSTRING --output-fd 1"

        SelectedDates=`eval $TEMPSTRING` #evaluates created dialog as if you typed it into command line
        
        #echo $SelectedDates| sed 's/ /,/g'
        #sed "s/ /,/g" <<< $SelectedDates
        SelectedDates=${SelectedDates// /,}

        LINEGET=`sed -n "$SelectedDates"p /tmp/calendars/Bcalendar`

     
    SelectDate=`dialog --calendar  "Select a new date" 0 0 --output-fd 1`
    StartTime=`dialog --timebox "Select a new event start time" 0 0 --output-fd 1`
    EndTime=`dialog --timebox "Select a new event end time" 0 0 --output-fd 1`
    Description=`dialog --inputbox "Select a new event description" 0 0 --output-fd 1`
    
    REPLACEMENT="$SelectDate $StartTime $EndTime $Description"
    
    sed -i 's_'"$LINEGET"'_'"$REPLACEMENT"'_g' /tmp/calendars/Bcalendar
fi
}


function display_appointments(){
    file=`wc -l < /tmp/calendars/Bcalendar`
    if [ $file -eq 0 ] # Checks if it's NULL thenn overrides the empty messagebox if it is
    then
        dialog --msgbox "You do not currently have any appointments" 0 0
    else

    events=$(</tmp/calendars/Bcalendar)
    dialog --msgbox "$events" 20 50

    fi
}


case $select in
    1)
        create_an_appointment
    ;;
    2)
        review_appointments
    ;;
    3)
        display_appointments
    ;;
    4)
       edit_appointments
esac

# TOdo:
# delete appointments : sed

# Edit appointments

# End time/start time


