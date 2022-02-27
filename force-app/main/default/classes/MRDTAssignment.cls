//MRDTAssignment Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Create assigned resource records for a collection of service appointments
//This class is currently not used as the flow was able to create the AR records directly
//Called by: Flow: MR_DT_Service_Appointment_Review
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

Public With Sharing Class MRDTAssignment {

    @InvocableMethod (label='MR DT Assign the Service Resources to the SAs')
    Public Static list<string> MRDTAssignment (list<list<serviceappointment>> listListSAs) {

        list<assignedresource> listNewAR = new list<assignedresource>();
        for(serviceappointment sa : listListSAs[0]) {

            if (sa.MR_Service_Resource__c != null) {
                listNewAR.add(new assignedresource(serviceappointmentid=sa.id,serviceresourceid=sa.MR_Service_Resource__c));
            }
                
        }
            
        if(Schema.sObjectType.assignedresource.isCreateable() && listNewAR.size()>0) {

            try{
                    insert listNewAR;
            }
            catch(DmlException e) {
                return new list<string>{e.getMessage()};
            }

        }
                
        return new list<string>{'Success'};
    }

}