@IsTest
public class MRDTDateShiftTestClass{

    @IsTest
    static void validateMRDTDateShift() {

        Map<String, SObject> testResourceMap = TestUtility.createSingleTestResource();
        WorkOrder wo = TestUtility.createWorkOrder('test', testResourceMap.get('WorkType').Id, testResourceMap.get('ServiceTerritory').Id);
        ServiceAppointment sa = TestUtility.createServiceAppointment(testResourceMap.get('ServiceResource').Id, wo.Id, Datetime.now(), Datetime.now().addDays(7), Datetime.now(), Datetime.now().addHours(1), 'Scheduled');

        list<serviceappointment> listSA = new list<serviceappointment>([SELECT 
                                                                        AppointmentNumber,
                                                                        EarliestStartTime,
                                                                        DueDate,
                                                                        SchedStartTime,
                                                                        SchedEndTime,
                                                                        MR_Service_Resource__c 
                                                                        FROM ServiceAppointment 
                                                                        WHERE ParentRecordId = :wo.Id]);

        MRDTDateShift.WODTSchedulePayload payload = new MRDTDateShift.WODTSchedulePayload();
        payload.listSA = listSA;
        payload.dateStarting = date.today();
        payload.dateEnding = date.today().adddays(7);
        payload.dateNewStart = date.today().adddays(100);

        List<MRDTDateShift.WODTSchedulePayload> inputList = new List<MRDTDateShift.WODTSchedulePayload>{payload};

        Test.startTest();
        List<MRDTDateShift.WODTScheduleOutput> outputList = MRDTDateShift.DateShift(inputList);
        Test.stopTest();

        System.assert(outputList.size() == 1);
        System.assert(outputList[0].listSA.size() == 1);
        System.assert(outputList[0].numSAs == 1);
    

    }



}