@IsTest
public class MRDTGetTimeZoneInfoTestClass{

    @IsTest
    static  void validateMRDTGetTimeZoneInfo() {

        OperatingHours oh = TestUtility.createOperatingHours('test', 'Antarctica/McMurdo');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);

        //MRDTGetSTMs.inPayLoad payload1 = new MRDTGetSTMs.inPayLoad();

        List<String> inputList = new List<String>{st.Id};

        Test.startTest();
        List<MRDTGetTimeZoneInfo.payLoadOut> payLoadOutList = MRDTGetTimeZoneInfo.MRDTGetTimeZoneInfo(inputList);
        Test.stopTest();

        System.assert(payLoadOutList.size() > 0);
        System.assertEquals(payLoadOutList[0].territoryTimeZone, oh.TimeZone);
        System.assertEquals(payLoadOutList[0].yourTimeZone, UserInfo.getTimeZone().getID());
    }

}