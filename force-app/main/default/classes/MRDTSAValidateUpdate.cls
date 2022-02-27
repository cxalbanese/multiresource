//MRDTSAUpdateValidate Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Update any SAs which have mismatch between MR Resource and AR.ServiceResource and return list of SAs return count of SAs
//If an SA is reassigned by a scheduling action, drag and drop or manual update, this class will update the MR_Service_Resource__c lookup to match
//Called by: Flow: MR_DT_Service_Appointment_Review
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public With Sharing class MRDTSAValidateUpdate {

@invocableMethod (label='MR DT Validate Update')
public static list<WODTScheduleOutput> SAValidateUpdate (list<WODTSchedulePayload> inPayloadList) {

    WODTSchedulePayload iPL = inPayloadList[0];
    string woID = iPL.woID;
    WODTScheduleOutput wOutput = new WODTScheduleOutput();
    wOutput.listSA = new list<serviceappointment>();
    wOutput.numSAs = 0;
    list<ServiceAppointment> listSA = new List<ServiceAppointment>();
    list<AssignedResource> listAR = new List<AssignedResource>();
    try{
        if(Schema.sObjectType.serviceappointment.isQueryable() && Schema.sObjectType.assignedresource.isQueryable()) {    
            listSA = [select id, appointmentnumber,schedstarttime,schedendtime,durationtype,duration,earlieststarttime,duedate,mr_creation_status__c,mr_service_resource__c,status,statuscategory from serviceappointment where parentrecordid = :woID or mr_parent_work_order__c = :woID];
            listAR = [select id,serviceappointmentid,serviceresourceid from assignedresource where serviceappointmentid in :listSA];}
        map<id,id> mapSAAR = new map<id,id>();
        for(assignedresource ar : listAR) mapSAAR.put(ar.serviceappointmentid,ar.serviceresourceid);
        list<serviceappointment> listUpdatedSA = new list<serviceappointment>();
        for(serviceappointment sa : listSA) 
            if(sa.mr_service_resource__c != mapSAAR.get(sa.id)) {
                sa.mr_service_resource__c = mapSAAR.get(sa.id);
                listUpdatedSA.add(sa);}
        if (Schema.sObjectType.serviceappointment.isUpdateable() && listUpdatedSA.size()>0) update listUpdatedSA;
        if(Schema.sObjectType.serviceappointment.isQueryable())
            wOutput.listSA = [select id, appointmentnumber,schedstarttime,schedendtime,durationtype,duration,earlieststarttime,duedate,mr_creation_status__c,mr_service_resource__c,status,statuscategory from serviceappointment where parentrecordid = :woID or mr_parent_work_order__c = :woID];
        wOutput.numSAs = wOutput.listSA.size();
        return new list<WODTScheduleOutput>{wOutput};
        }
    catch(exception e) {
        return new list<WODTScheduleOutput>{wOutput};    
    }
}

public class WODTSchedulePayload {
  
@invocableVariable public string woID;
}

public class WODTScheduleOutput {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public integer numSAs;
}
}