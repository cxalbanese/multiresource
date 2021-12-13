Public Class MRDTAssignment {

@invocableMethod (label='MR DT Assign the Service Resources to the SAs')
Public Static list<string> MRDTAssignment (list<list<serviceappointment>> listListSAs) {

    list<assignedresource> listNewAR = new list<assignedresource>();
    for(serviceappointment sa : listListSAs[0]) 
        if (sa.MR_Service_Resource__c != null) 
            listNewAR.add(new assignedresource(serviceappointmentid=sa.id,serviceresourceid=sa.MR_Service_Resource__c));
    if(listNewAR.size()>0) 
    try{insert listNewAR;}
    catch(DmlException e) {
        return new list<string>{e.getMessage()};}        
            
    return new list<string>{'Success'};
}
}