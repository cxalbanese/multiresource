@IsTest
public class MRDTGetSTMsTestClass{

    OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
    ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
    //Skill sk = TestUtility.createSkill('test', 'test');
    String userId = UserInfo.getUserId(); 
    ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
    ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
    ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));

    @IsTest
    static void testSTMsWithAllSkills() {

        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = 'All';
        payload.inSkillId = 'All';
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());

    }

    /* @Is@TestSetup
    static void testSTMsWithSpecificSkills(){

        MRDTGetSTMs.inPayLoad payload1 = new MRDTGetSTMs.inPayLoad();
        payload1.inTerritoryId = st.id;
        payload1.inSkillId = sk.id;
        payload1.startDate = date.today();
        payload1.enddate = date.today().adddays(7);

        list<MRDTGetSTMs.inPayLoad> inputList1 = new list<MRDTGetSTMs.inPayLoad>{payload1};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList1 = MRDTGetSTMs.GetSTMS(inputList1);
        Test.stopTest();


        
    } */

}