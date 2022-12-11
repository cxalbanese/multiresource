//MRDTGetOverlapInfo Author: Chris Albanese, Version 1, Created Oct 31, 2022
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
        system.debug('(((((((((( initial map for resource ' + mapSROverlapProfile);
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
                string dow = ar.ServiceAppointment.SchedStartTime.format('EEE');
                if((dow == weekendDay1 && includeWeekendDay1) || 
                    (dow == weekendDay2 && includeWeekendDay2) || 
                    (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                mapSROverlapProfile.put(ar.ServiceResourceId,
                    calcOverlap(ar.ServiceResourceId, ar.ServiceAppointment.SchedStartTime, ar.ServiceAppointment.SchedEndTime, ar.ServiceAppointment.DurationInMinutes, netNumDays, ar.ServiceAppointment.AppointmentNumber,ar.ServiceAppointment.Subject));
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
            //if we found RAs, lets add them to the overlapProfile     
            for(resourceabsence ra : raList) {
                string dow = ra.start.format('EEE');
                if((dow == weekendDay1 && includeWeekendDay1) || 
                    (dow == weekendDay2 && includeWeekendDay2) || 
                    (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                        mapSROverlapProfile.put(ra.resourceid,
                            calcOverlap(ra.ResourceId, ra.Start, ra.End, ra.FSL__Duration_In_Minutes__c, netNumDays, ra.AbsenceNumber,ra.Type));
                }
    }
}
    public MRDTresourceOverlaps calcOverlap(string resourceId,datetime startTime,datetime endTime,decimal duration,integer numDays,string recordName,string recordDesc) {
        date arDate = startTime.date();
        MRDTresourceOverlaps thisOverlap = new MRDTresourceOverlaps();
        thisOverlap = mapSROverlapProfile.get(resourceId);
        thisOverlap.numberConflicts++;
        thisOverlap.totalBlockedHours+=duration/60;
        if(numdays!=0)
            thisOverlap.percentAvailability=(1-thisOverlap.numberConflicts/numDays)*100;     
        else 
            thisOverlap.percentAvailability=0;
        MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
        sCD = thisOverlap.mapSAConflictDetails.get(arDate);
        sCD.blockedHours+=duration/60;
        string overlapString = recordName+'-'+recordDesc+'-'+startTime.format('h:mm a')+'-'+endTime.format('h:mm a');
        if(sCD.conflictDetails!='' && sCD.conflictDetails.length()< 255-overlapString.length())
            sCD.conflictDetails+=','+overlapString;
        else 
            sCD.conflictDetails=overlapString;
        thisOverlap.mapSAConflictDetails.put(arDate,sCD);
        return(thisOverlap);      
    }
    
}
