//MRDTGetOverlapInfo Author: Chris Albanese, Version 1, Created Oct 31, 2022
//updated March 10, 2023 to handle multi-day resource absence and simply availability calculation
//Purpose: get a list of overlapping SAs, RAs for a list of Technicians
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
public with sharing class MRDTGetOverlapInfo {
    //this is the list of resource ids along with a overlap information
    public map<id,MRDTresourceOverlaps> mapSROverlapProfile = new map<id,MRDTresourceOverlaps>();
    public MRDTGetOverlapInfo(set<string> setResourceId,
                                datetime startDateTime,
                                datetime endDateTime,
                                boolean includeWeekendDay1,
                                boolean includeWeekendDay2,
                                boolean includeOnlyWeekends,
                                string weekendDay1,
                                string weekendDay2) {
        //this is the number of days between the start and end date times                            
        integer numDays = startDateTime.date().daysBetween(endDateTime.date());
        //this will be calculated to be the the number of days between the 2 dates coonsidering
        //whether weekends are excluded or included or only weekends are selected
        integer netNumDays=0;
        for(integer x =0 ; x<numDays; x++) {
            string dow = startDateTime.addDays(x).format('EEE');
            if((dow == weekendDay1 && includeWeekendDay1) || 
                (dow == weekendDay2 && includeWeekendDay2) || 
                (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                    netNumDays++;
        }
        //updated 3/25/2023 subtract 1 second from end date to make sure we don't include overlaps past the end date
        endDateTime=endDateTime.addSeconds(-1);
        //get the list of resource names 
        map<string,string> mapResourceName = new Map<string,string>();
        if(Schema.sObjectType.serviceresource.isQueryable()) {     
            for(serviceresource thisSR : [select id,name from serviceresource where id in :setResourceId]){
                mapResourceName.put(thisSR.id,thisSR.Name);
            }
        } 
        //initialize the map
        //intialize all of the days between the start and end for this resourc
        for(string thisResourceId :setResourceId){
            MRDTresourceOverlaps thisOverlap = new MRDTresourceOverlaps();
            thisOverlap.netNumDays = netNumDays;
            thisOverlap.resourceId = thisResourceId;
            thisOverlap.resourceName = mapResourceName.get(thisResourceId);
            thisOverlap.numberConflicts=0;
            thisOverlap.totalBlockedHours=0;
            thisOverlap.percentAvailability=100;
            thisOverlap.stringnumberConflicts='0';
            thisOverlap.stringpercentAvailability='100';
            thisOverlap.skillLevelsMatched='';
            thisOverlap.skillNamesMatched='';
            thisOverlap.skillsMatched='';
            //initialize the map of daily conflicts for each resource
            map<date,MRDTresourceOverlaps.saConflictDetails> mapSAConflictDetails=  new map<date,MRDTresourceOverlaps.saConflictDetails> ();
            for(integer thisDayNumber=0;thisDayNumber <= numDays;thisDayNumber++ ){
                MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
                sCD.blockedHours=0;
                sCD.conflictDetails='';
                mapSAConflictDetails.put(startDateTime.date().addDays(thisDayNumber),sCD);
            }
            thisOverlap.mapSAConflictDetails = mapSAConflictDetails;
            mapSROverlapProfile.put(thisResourceId,thisOverlap);
        }
        list<ovlapExploded> ovlapExplodedList = new list<ovlapExploded>();  
        //let's check overlaps with Service Appointments
        list<assignedresource> arList = new list<assignedresource>();
        if(Schema.sObjectType.assignedresource.isQueryable() && Schema.sObjectType.serviceappointment.isQueryable()){
            arList = [select 
                id,
                serviceresourceid,
                ServiceAppointment.AppointmentNumber,
                ServiceAppointment.SchedStartTime,
                ServiceAppointment.DurationInMinutes,               
                ServiceAppointment.SchedEndtime,
                ServiceAppointment.Subject
                from assignedresource 
                where 
                serviceresourceid in :setResourceId and 
                serviceappointmentid in (
                    select id from serviceappointment 
                    where 
                        /* serviceterritoryid in :listST and ******* removed in case there are secondary territories */
                        /* statuscategory not in  ('Canceled','None') and ******** add this back if there categories you want to filter */
                        schedstarttime < :endDateTime and schedendtime > :startDateTime)
                Order by ServiceAppointment.SchedStartTime]; 
            //if we found SAs, lets add them to the overlapProfile     
            for(assignedResource ar : arList) {
                ovlapExplodedList.addAll(explodeOverlap(ar.ServiceResourceId, ar.ServiceAppointment.SchedStartTime, ar.ServiceAppointment.SchedEndTime, ar.ServiceAppointment.AppointmentNumber, ar.ServiceAppointment.Subject,startDateTime,endDateTime));   
            }
        }
    
        //let's see if there are any resource absences for the resources during the selected period of time  
        Final Id nonAvailRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
        list<resourceabsence> raList = new list<resourceabsence>();
        if(Schema.sObjectType.resourceabsence.isQueryable()) {
            raList = [select 
                    id,
                    resourceId,
                    AbsenceNumber,
                    FSL__Duration_In_Minutes__c,
                    Start,
                    End,
                    Type
                    from 
                    resourceabsence 
                    where 
                    ResourceId in :setResourceId and 
                    recordtypeid = :nonAvailRecordTypeId and 
                    start < :endDateTime and end > :startDateTime 
                    order by Start];
            for(resourceabsence ra : ralist) {
                ovlapExplodedList.addAll(explodeOverlap(ra.ResourceId, ra.Start, ra.End, ra.AbsenceNumber, ra.Type,startDateTime,endDateTime));   

            }
    }            
    for(ovlapExploded ra : ovlapExplodedList) {
        string dow = ra.startDateTime.format('EEE');
        if((dow == weekendDay1 && includeWeekendDay1) || 
            (dow == weekendDay2 && includeWeekendDay2) || 
            (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                mapSROverlapProfile.put(ra.resourceid,
                    calcOverlap(ra.resourceId, ra.startDateTime, ra.endDateTime, ra.durationInMinutes, netNumDays, ra.ovlapNumber,ra.type));
    }
}
    public list<ovlapExploded> explodeOverlap(string resourceId,datetime startTime,datetime endTime,string recordName,string recordDesc,datetime startDateTime, Datetime endDateTime) {
        //we will expand multi-day resource absences and service appointments into daily pieces
        //if RA/SA is mult-day then day1 start = ra/sa start and end = day 1 23:59
        //day x = day x 00:00 ->  day x 23:59
        //last day start = 00:00 and end = ra/sa end 
        //calc the # days long the RA/SA is
        list<ovlapExploded> ovlapExplodedList = new list<ovlapExploded>();   
        integer numDaysRASA = startTime.date().daysBetween(endTime.date());     
        //loop through the number of days long the RA/SA is, even if it's < 1 day           
        for(Integer x = 0; x <= numDaysRASA; x++  ){
            DateTime rasaStartDateTime = startTime;
            DateTime rasaEndDateTime = endTime;
            //if it's less than 1 day or we are at day 1 set the start time
            if(x==0) rasaStartDateTime = startTime;           
            //if it's less than 1 day set the end time = ra.end     
            if(numDaysRASA == 0) rasaEndDateTime = endTime; 
            //if it's longer than 1 day increment to the next day               
            if(x>0) rasaStartDateTime = datetime.newInstance(startTime.date().adddays(x),time.newInstance(0, 0, 0, 0));
            //if we're at the last day, set the end time = ra/sa.End                
            if (x > 0 && x == numDaysRASA) rasaEndDateTime = endTime;
            //if there's more than 1 day and we're not at the end send the end time to the end of the current day                
            if ( x < numDaysRASA && numDaysRASA > 0) {
                //if this is the first day of a multi-day RA/SA set the end of the day to midnight
                if(x == 0)
                    rasaEndDateTime = datetime.newInstance(startTime.date(),time.newInstance(23, 59, 59, 0));
                else                        
                    rasaEndDateTime = rasaStartDateTime.addHours(23).addMinutes(59).addSeconds(59); 
            }
            //add the exploded RA/SA to the list
            //updated 3/25/2023 added check to eliminate before/after of multi-day ra or sa
            if(rasaStartDateTime.date() >= startDateTime.date() && rasaEndDateTime.date()<=endDateTime.date() ) {
                ovlapExploded rasaEX = new ovlapExploded();
                rasaEX.resourceId = resourceId;
                rasaEX.ovlapNumber = recordName;
                rasaEX.startDateTime = rasaStartDateTime;
                rasaEX.endDateTime = rasaEndDateTime;
                rasaEX.type = recordDesc;
                rasaEX.durationInMinutes = ((rasaEndDateTime.getTime() - rasaStartDateTime.getTime()) / 1000) / 60;
                ovlapExplodedList.add(rasaEX);
            }
        }
        return ovlapExplodedList;
    }
    public MRDTresourceOverlaps calcOverlap(string resourceId,datetime startTime,datetime endTime,decimal duration,integer numDays,string recordName,string recordDesc) {
        date arDate = startTime.date();
        MRDTresourceOverlaps thisOverlap = new MRDTresourceOverlaps();
        thisOverlap = mapSROverlapProfile.get(resourceId);
        MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
        sCD = thisOverlap.mapSAConflictDetails.get(arDate);
        //cxa added if statement to have overlap indicated once per day regardless of how many overlaps were detected in a single day
        if(sCD.blockedHours==0) thisOverlap.numberConflicts++;
        thisOverlap.totalBlockedHours+=duration/60;
        if(numdays!=0)
            thisOverlap.percentAvailability=(1-thisOverlap.numberConflicts/numDays)*100;     
        else 
            thisOverlap.percentAvailability=0;
        //cxa moved to higher in this method MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
        //cxa moved to higher in this method sCD = thisOverlap.mapSAConflictDetails.get(arDate);
        sCD.blockedHours+=duration/60;
        string overlapString = recordName+'-'+recordDesc+'-'+startTime.format('h:mm a')+'-'+endTime.format('h:mm a');
        if(sCD.conflictDetails!='' && sCD.conflictDetails.length()< 255-overlapString.length())
            sCD.conflictDetails+=','+overlapString;
        else 
            sCD.conflictDetails=overlapString;
        thisOverlap.mapSAConflictDetails.put(arDate,sCD);
        return(thisOverlap);      
    }
    public class ovlapExploded{
        public String ovlapNumber;
        public DateTime startDateTime;
        public DateTime endDateTime;
        public Double durationInMinutes;
        public String type;
        public Id resourceId;

    }
    
}
