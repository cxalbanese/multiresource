//MRDTReassignTechs Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Reassign selected SAs to a new Service Resource
//Called by: Flow: MR_DT_Service_Appointment_Review
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public With Sharing class MRDTReassignTechs {
// this reassigns Techs on selected SAs
@invocableMethod(label='MR DT Reassign Techs')
public static list<string> ReassignTechs (list<inPayLoad> listPayload) {
    String serviceResourceId = listPayload[0].serviceResourceId;
    list<serviceappointment> listSA = new list<serviceappointment>(listPayload[0].listSA);
    list<assignedresource> listAR = new list<assignedresource>();
    
    try{
    if(Schema.sObjectType.assignedresource.isQueryable())
        listAR = [select id,serviceappointmentid from assignedresource where serviceappointmentid in : listSA];
    list<assignedresource> listNewAR = new list<assignedresource>();
    list<serviceappointment> listUpdSA = new list<serviceappointment>();
    for(assignedresource ar : listAR) 
        listNewAR.add(new assignedresource(serviceresourceid=serviceResourceId,serviceappointmentid=ar.serviceappointmentid));
    if(Schema.sObjectType.assignedresource.isUpdateable() && Schema.sObjectType.assignedresource.isCreateable() && Schema.sObjectType.assignedresource.isDeletable() && listNewAR.size()>0) {
        insert listNewAR;
        delete listAR;
        for(serviceappointment sa : listSA) {
            sa.mr_service_resource__c = serviceResourceId;
            listUpdSA.add(sa);}
        if(listUpdSA.size()>0) update listUpdSA;
        }
    }
    catch(exception e) {
        return new list<string>{e.getMessage()};}
    
    return new list<string>{'Success'};

}

public class inPayLoad{
@invocableVariable
public string serviceResourceId;
@invocableVariable
public list<serviceappointment> listSA;
}

}