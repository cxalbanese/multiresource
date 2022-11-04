//MRDTGetOverlapInfo Author: Chris Albanese, Version 1, Created Oct 31, 2022
//Purpose: get a list of overlapping SAs, RAs for a list of Technicians
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
public with sharing class MRDTGetOverlapInfo {
    //this is the list of resource ids along with a overlap information
    public map<id,MRDTresourceOverlaps> mapSROverlapProfile = new map<id,MRDTresourceOverlaps>();
    public MRDTGetOverlapInfo(set<string> setResourceId,datetime startDateTime,datetime endDateTime) {
        integer numDays = startDateTime.date().daysBetween(endDateTime.date());
        //initialize the map
        //intialize all of the days between the start and end for this resource
        map<date,MRDTresourceOverlaps.saConflictDetails> SAConflictDetails= new Map<Date,MRDTresourceOverlaps.saConflictDetails>();
        for(integer thisDayNumber=0;thisDayNumber < numDays;thisDayNumber++ ){
            MRDTresourceOverlaps.saConflictDetails sCD = new MRDTresourceOverlaps.saConflictDetails();
            sCD.blockedHours=0;
            sCD.conflictDetails='';
            SAConflictDetails.put(startDateTime.date().addDays(thisDayNumber),sCD);
        }
        for(string thisResourceId :setResourceId){
            MRDTresourceOverlaps thisOverlap = new MRDTresourceOverlaps();
            thisOverlap.resourceId = thisResourceId;
            thisOverlap.numberConflicts=0;
            thisOverlap.totalBlockedHours=0;
            thisOverlap.percentAvailability=0;
            thisOverlap.stringnumberConflicts='';
            thisOverlap.stringpercentAvailability='';
            //intialize all of the days between the start and end for this resource
            thisOverlap.mapSAConflictDetails = SAConflictDetails;
            mapSROverlapProfile.put(thisResourceId,thisOverlap);
        }
        //let's see if there are any resource absences for the resources during the selected period of time  
        Final Id nonAvailRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
        list<resourceabsence> raList = new list<resourceabsence>();
        if(Schema.sObjectType.resourceabsence.isQueryable()) 
            raList = [select 
                    id,
                    resourceId,
                    AbsenceNumber,
                    FSL__Duration_In_Minutes__c,
                    Start,
                    End
                    from 
                    resourceabsence 
                    where 
                    ResourceId in :setResourceId and 
                    recordtypeid = :nonAvailRecordTypeId and 
                    start < :endDateTime and end > :startDateTime ];

        //if we found RAs, lets add them to the overlapProfile     
        for(resourceabsence ra : raList) {
            date raDate = ra.Start.date();
            MRDTresourceOverlaps thisOverlap = mapSROverlapProfile.get(ra.ResourceId);
            thisOverlap.numberConflicts++;
            thisOverlap.totalBlockedHours+=ra.FSL__Duration_In_Minutes__c/60;
            if(numdays!=0)
                thisOverlap.percentAvailability=thisOverlap.numberConflicts/numDays;     
            else 
               thisOverlap.percentAvailability=0;
            MRDTresourceOverlaps.saConflictDetails sCD = thisOverlap.mapSAConflictDetails.get(raDate);
            sCD.blockedHours+=ra.FSL__Duration_In_Minutes__c/60;
            if(sCD.conflictDetails!='')
                sCD.conflictDetails+=','+ra.AbsenceNumber;
            else 
                sCD.conflictDetails=ra.AbsenceNumber;
            thisOverlap.mapSAConflictDetails.put(raDate,sCD);
            mapSROverlapProfile.put(ra.resourceid,thisOverlap);
        }
        //now let's check overlaps with Service Appointments
        list<assignedresource> arList = new list<assignedresource>();
        if(Schema.sObjectType.assignedresource.isQueryable()){
            arList = [select 
                id,
                serviceresourceid,
                ServiceAppointment.AppointmentNumber,
                ServiceAppointment.SchedStartTime,
                ServiceAppointment.DurationInMinutes,               
                ServiceAppointment.SchedEndtime
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
                date arDate = ar.ServiceAppointment.SchedStartTime.date();
                MRDTresourceOverlaps thisOverlap = mapSROverlapProfile.get(ar.ServiceResourceId);
                thisOverlap.numberConflicts++;
                thisOverlap.totalBlockedHours+=ar.ServiceAppointment.DurationInMinutes/60;
                if(numdays!=0)
                    thisOverlap.percentAvailability=thisOverlap.numberConflicts/numDays;     
                else 
                    thisOverlap.percentAvailability=0;
                MRDTresourceOverlaps.saConflictDetails sCD = thisOverlap.mapSAConflictDetails.get(arDate);
                sCD.blockedHours+=ar.ServiceAppointment.DurationInMinutes/60;
                if(sCD.conflictDetails!='')
                    sCD.conflictDetails+=','+ar.ServiceAppointment.AppointmentNumber;
                else 
                    sCD.conflictDetails=ar.ServiceAppointment.AppointmentNumber;
                thisOverlap.mapSAConflictDetails.put(arDate,sCD);
                mapSROverlapProfile.put(ar.ServiceResourceId,thisOverlap);
            }
        }
    }
    
}
