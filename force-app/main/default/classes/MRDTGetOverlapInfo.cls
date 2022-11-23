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
        integer numDays = startDateTime.date().daysBetween(endDateTime.date());
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
            thisOverlap.resourceId = thisResourceId;
            thisOverlap.resourceName = mapResourceName.get(thisResourceId);
            thisOverlap.numberConflicts=0;
            thisOverlap.totalBlockedHours=0;
            thisOverlap.percentAvailability=100;
            thisOverlap.stringnumberConflicts='0';
            thisOverlap.stringpercentAvailability='100';
            //initialize the map of daily conflicts for each resource
            map<date,MRDTresourceOverlaps.saConflictDetails> mapSAConflictDetails=  new map<date,MRDTresourceOverlaps.saConflictDetails> ();
            for(integer thisDayNumber=0;thisDayNumber < numDays;thisDayNumber++ ){
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
                        schedstarttime < :endDateTime and schedendtime > :startDateTime) ]; 
            //if we found SAs, lets add them to the overlapProfile     
            for(assignedResource ar : arList) {
                string dow = ar.ServiceAppointment.SchedStartTime.format('EEE');
                if((dow == weekendDay1 && includeWeekendDay1) || 
                    (dow == weekendDay2 && includeWeekendDay2) || 
                    (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                mapSROverlapProfile.put(ar.ServiceResourceId,
                    calcOverlap(ar.ServiceResourceId, ar.ServiceAppointment.SchedStartTime, ar.ServiceAppointment.DurationInMinutes, numDays, ar.ServiceAppointment.AppointmentNumber,ar.ServiceAppointment.Subject));
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
                    start < :endDateTime and end > :startDateTime ];
            //if we found RAs, lets add them to the overlapProfile     
            for(resourceabsence ra : raList) {
                string dow = ra.start.format('EEE');
                if((dow == weekendDay1 && includeWeekendDay1) || 
                    (dow == weekendDay2 && includeWeekendDay2) || 
                    (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends))
                        mapSROverlapProfile.put(ra.resourceid,
                            calcOverlap(ra.ResourceId, ra.Start, ra.FSL__Duration_In_Minutes__c, numDays, ra.AbsenceNumber,ra.Type));
                }
    }
}
    public MRDTresourceOverlaps calcOverlap(string resourceId,datetime startTime,decimal duration,integer numDays,string recordName,string recordDesc) {
        date arDate = startTime.date();
        MRDTresourceOverlaps thisOverlap = new MRDTresourceOverlaps();
        thisOverlap = mapSROverlapProfile.get(resourceId);
        system.debug('^^^^^^^^^ this overlap retrieval ' + thisOverlap);
        thisOverlap.numberConflicts++;
        thisOverlap.totalBlockedHours+=duration/60;
        if(numdays!=0)
            thisOverlap.percentAvailability=(1-thisOverlap.numberConflicts/numDays)*100;     
        else 
            thisOverlap.percentAvailability=0;
        MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
        sCD = thisOverlap.mapSAConflictDetails.get(arDate);
        system.debug('@@@@@@@@@@@@ this overlap map SA conflict details ' + sCD);
        sCD.blockedHours+=duration/60;
        if(sCD.conflictDetails!='')
            sCD.conflictDetails+=','+recordName+'-'+recordDesc;
        else 
            sCD.conflictDetails=recordName+'-'+recordDesc;
        thisOverlap.mapSAConflictDetails.put(arDate,sCD);
        System.debug('********** res date conflict details' + resourceId + ' '+arDate + ' ' + sCD.conflictDetails ); 
        System.debug('########## thisOverlap' + thisOverlap);
        System.debug('!!!!!!!!!! thisOverlap.mapSAConflictDetails' + thisOverlap.mapSAConflictDetails);
        return(thisOverlap);      
    }
    
}
