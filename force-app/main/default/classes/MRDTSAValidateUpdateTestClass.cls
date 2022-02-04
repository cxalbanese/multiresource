@isTest
public class MRDTSAValidateUpdateTestClass{
@isTest
static  void validateMRDTValidateUpdate() {

Map<String,SObject> testResourceMap = TestUtility.createSingleTestResource();
WorkOrder wo = TestUtility.createWorkOrder('test', testResourceMap.get('WorkType').Id, testResourceMap.get('ServiceTerritory').Id);
ServiceAppointment sa = TestUtility.createServiceAppointment(testResourceMap.get('ServiceResource').Id, wo.Id, datetime.now(), datetime.now().adddays(10), datetime.now(),datetime.now().addhours(1),'Scheduled');

MRDTSAValidateUpdate.WODTSchedulePayload payload = new MRDTSAValidateUpdate.WODTSchedulePayload();
payload.woID = wo.id;
list<MRDTSAValidateUpdate.WODTSchedulePayload> inputList = new list<MRDTSAValidateUpdate.WODTSchedulePayload>{payload};

test.startTest();
list<MRDTSAValidateUpdate.WODTScheduleOutput> outputList = MRDTSAValidateUpdate.SAValidateUpdate(inputList);
test.stopTest();

system.assert(!outputList.isEmpty(), 'list should not be empty');
system.assert(outputList[0].numSAs>0, 'numSAs should be greater than 0 ');
}


}