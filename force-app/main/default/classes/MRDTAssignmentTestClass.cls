@isTest
public class MRDTAssignmentTestClass{

    @IsTest
    static void validateMRDTAssignment() {

        Map<String, SObject> testResourceMap = TestUtility.createSingleTestResource();
        WorkOrder wo = TestUtility.createWorkOrder('test', testResourceMap.get('WorkType').Id, testResourceMap.get('ServiceTerritory').Id);
        ServiceAppointment sa = TestUtility.createServiceAppointment(testResourceMap.get('ServiceResource').Id, wo.Id, Datetime.now(), Datetime.now().addDays(7), Datetime.now(), Datetime.now().addHours(1));

        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>{sa};
        List<List<ServiceAppointment>> nestedServiceAppointmentList = new List<List<ServiceAppointment>>{serviceAppointmentList};

        Test.startTest();
        List<String> resultList = MRDTAssignment.MRDTAssignment(nestedServiceAppointmentList);
        Test.stopTest();  
        System.assertEquals('Success', resultList[0]);
    }
}