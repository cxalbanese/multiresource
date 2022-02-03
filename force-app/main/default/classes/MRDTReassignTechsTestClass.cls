@isTest
public class MRDTReassignTechsTestClass{

    @IsTest
    static void validateReassignTechs() {

        List<User> userList = TestUtility.createUser(2);
        Map<String,SObject> testResource1 = TestUtility.createSingleTestResource(userList[0].Id);
        Map<String,SObject> testResource2 = TestUtility.createSingleTestResource(userList[1].Id);

        WorkType wt = TestUtility.createWorktype('test', 1, 'hours');
        WorkOrder wo = TestUtility.createWorkOrder('test', wt.Id, testResource1.get('ServiceTerritory').Id);
        ServiceAppointment sa = TestUtility.createServiceAppointment(testResource1.get('ServiceResource').Id, wo.Id, Datetime.now(), Datetime.now().addDays(7), Datetime.now(), Datetime.now().addHours(1));
        AssignedResource ar = TestUtility.createAssignedResource(sa.Id, testResource1.get('ServiceResource').Id);

        List<ServiceAppointment> listsa = new List<ServiceAppointment> {sa};
        MRDTReassignTechs.inPayLoad inPayload = new MRDTReassignTechs.inPayLoad();
        inPayload.serviceResourceId = testResource2.get('ServiceResource').Id;
        inPayload.listSA = listsa;

        Test.startTest();
        List<String> results = MRDTReassignTechs.ReassignTechs(new List<MRDTReassignTechs.inPayLoad>{inPayload});
        Test.stopTest();

        ServiceAppointment updatedSA = [SELECT mr_service_resource__c FROM ServiceAppointment WHERE Id = :sa.Id];
        System.assert(!results.isEmpty());
        System.assertEquals('Success', results[0]);
        System.assertEquals(inPayload.serviceResourceId, updatedSA.MR_Service_Resource__c);

    }



}