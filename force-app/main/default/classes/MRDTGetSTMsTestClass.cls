@IsTest
public class MRDTGetSTMsTestClass{

    @IsTest
    static void testSTMsWithAllSkillsAllTerritories() {
        
        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = 'All';
        payload.inSkillId = 'All';
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }


    @IsTest
    static void testSTMsWithAllSkillsAllTerritoriesWithOverlap() {
        
        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        ServiceAppointment sa = TestUtility.createServiceAppointment(sr.Id, wo.Id, Datetime.now(), Datetime.now().addDays(4), Datetime.now(), Datetime.now().addHours(2), 'Scheduled', st.Id);
        AssignedResource ar = TestUtility.createAssignedResource(sa.Id, sr.Id);
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = 'All';
        payload.inSkillId = 'All';
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;
        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }


    @IsTest
    static void testSTMsWithAllSkillsAllTerritoriesWithMultipleSAs() {
        
        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        //ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        ServiceAppointment sa = TestUtility.createServiceAppointment(sr.Id, wo.Id, Datetime.now(), Datetime.now().addDays(4), Datetime.now(), Datetime.now().addHours(2), 'Scheduled', st.Id);
        AssignedResource ar = TestUtility.createAssignedResource(sa.Id, sr.Id);
        ServiceAppointment sa1 = TestUtility.createServiceAppointment(sr.Id, wo.Id, Datetime.now(), Datetime.now().addDays(4), Datetime.now(), Datetime.now().addHours(2), 'Scheduled', st.Id);
        AssignedResource ar1 = TestUtility.createAssignedResource(sa1.Id, sr.Id);
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = 'All';
        payload.inSkillId = 'All';
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }


    @IsTest
    static void testSTMsSpecificSkillAllTerritories(){

        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = 'All';
        payload.inSkillId = resourceSkill.SkillId;
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }


    @IsTest
    static void testSTMsWithAllSkillsSpecificTerritory(){

        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = st.Id;
        payload.inSkillId = 'All';
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }


    @IsTest
    static void testSTMsSpecificSkillsSpecificTerritory(){

        OperatingHours oh = TestUtility.createOperatingHours('test', 'America/Los_Angeles');
        ServiceTerritory st = TestUtility.createServiceTerritory('test', true, oh.Id);
        String userId = UserInfo.getUserId(); 
        ServiceResource sr = TestUtility.createServiceResource('test', true, userId, 'T');
        ServiceResourceSkill resourceSkill = TestUtility.createServiceResourceSkill(sr.Id);
        ServiceTerritoryMember stm = TestUtility.createServiceTerritoryMember(sr.Id, st.Id, Datetime.now().addDays(-1));
        ResourceAbsence ra = TestUtility.createResourceAbsence(sr.Id, Datetime.now(), Datetime.now().addHours(4));
        WorkOrder wo = TestUtility.createWorkOrder();
        MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();
        payload.inTerritoryId = st.Id;
        payload.inSkillId = resourceSkill.SkillId;
        payload.startDate = date.today();
        payload.enddate = date.today().adddays(7);
        payload.inWoId =wo.Id;
        payload.includeOnlyWeekends = false;
        payload.includeWeekendDay1 = false;
        payload.includeWeekendDay2 = false;

        list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

        Test.startTest();
        list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);
        Test.stopTest();

        System.assert(!outputList.isEmpty());
        System.assertEquals('warning', outputList[0].overlapWarning);
        System.assertEquals(stm.Id, outputList[0].stmList[0].Id);

    }

}