@isTest
public class MRDTSchedMultiVisitTestClass{
@isTest
static  void validateMRDTSchedMultiVisit() {

Map<String,SObject> testResourceMap = TestUtility.createSingleTestResource();
WorkOrder wo = TestUtility.createWorkOrder('test', testResourceMap.get('WorkType').Id, testResourceMap.get('ServiceTerritory').Id);
ServiceTerritory st = (ServiceTerritory)testResourceMap.get('ServiceTerritory');
ServiceTerritoryMember stm = (ServiceTerritoryMember)testResourceMap.get('ServiceTerritoryMember');
ServiceResource sr = (ServiceResource)testResourceMap.get('ServiceResource');
ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
ServiceAppointment sa = TestUtility.createServiceAppointment(sr.Id, wo.Id, Datetime.now(), Datetime.now().addDays(4), Datetime.now(), Datetime.now().addHours(2), 'Scheduled', st.Id);
AssignedResource ar = TestUtility.createAssignedResource(sa.Id, sr.Id);
MRDTSchedMultiVisit.WODTSchedulePayload payload = new MRDTSchedMultiVisit.WODTSchedulePayload();
payload.listSTM = new list<serviceterritorymember>{stm};
payload.territoryId = st.id;
payload.workorderid=wo.id;
payload.starting = date.today();
payload.until = date.today().adddays(7);
payload.startTime = '08:00 AM';
payload.defaultDuration = 8;
payload.status = 'Scheduled';
payload.taskDescription = 'test';
payload.limitSAs = 100;
payload.includeWeekendDay1 = true;
payload.includeWeekendDay2 = true;
payload.includeOnlyWeekends = false;
list<MRDTSchedMultiVisit.WODTSchedulePayload> inputList = new list<MRDTSchedMultiVisit.WODTSchedulePayload>{payload};
test.startTest();
list<MRDTSchedMultiVisit.WODTScheduleOutput> outputList = MRDTSchedMultiVisit.MRDTMV(inputList);
test.stopTest();

system.assert(!outputList.isEmpty(), 'list should not be empty');

}



}