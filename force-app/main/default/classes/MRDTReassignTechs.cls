public class MRDTReassignTechs {
// this reassigns Techs on selected SAs
@invocableMethod(label='MR DT Reassign Techs')
public static list<string> ReassignTechs (list<inPayLoad> listPayload) {
    String serviceResourceId = listPayload[0].serviceResourceId;
    list<serviceappointment> listSA = new list<serviceappointment>(listPayload[0].listSA);
    list<assignedresource> listAR = new list<assignedresource>();
    
    try{
    listAR = [select id,serviceappointmentid from assignedresource where serviceappointmentid in : listSA];
    list<assignedresource> listNewAR = new list<assignedresource>();
    list<serviceappointment> listUpdSA = new list<serviceappointment>();
    for(assignedresource ar : listAR) 
        listNewAR.add(new assignedresource(serviceresourceid=serviceResourceId,serviceappointmentid=ar.serviceappointmentid));
    if(listNewAR.size()>0) {
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