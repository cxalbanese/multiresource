@isTest
public with sharing class TestUtility {
    public TestUtility() {

    }

    public static WorkType createWorktype(String worktypeName, Double estDuration, String durationType){

        WorkType testWorkType = new WorkType(Name = worktypeName,
                                            EstimatedDuration = estDuration,
                                            DurationType = durationType);

        insert testWorkType;                            
        return testWorkType;

    }


    public static OperatingHours createOperatingHours(String ohName){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName);
        
        insert testOperatingHours;
        return testOperatingHours;

    }

    public static OperatingHours createOperatingHours(String ohName, String tz){

        OperatingHours testOperatingHours = new OperatingHours(Name = ohName, 
                                                               TimeZone = tz);
        
        insert testOperatingHours;
        return testOperatingHours;

    }


    public static ServiceTerritory createServiceTerritory(String territoryName,Boolean active, String opHoursId){

        ServiceTerritory testServiceTerritory = new ServiceTerritory(Name = territoryName,
                                                                     IsActive = active,
                                                                     OperatingHoursId = opHoursId);

        insert testServiceTerritory;
        return testServiceTerritory;

    }


    public static ServiceResource createServiceResource(String resourceName, Boolean active, String relatedRecord, String resourceType){

        ServiceResource testServiceResource = new ServiceResource(Name = resourceName,
                                                                  IsActive = active,
                                                                  relatedRecordId = relatedRecord,
                                                                  ResourceType = resourceType);

        insert testServiceResource;
        return testServiceResource;

    }


    public static ServiceTerritoryMember createServiceTerritoryMember(String resourceId, String territoryId, Datetime startDate){

        ServiceTerritoryMember testStm = new ServiceTerritoryMember(ServiceResourceid = resourceId,
                                                                    ServiceTerritoryId = territoryId,
                                                                    EffectiveStartDate = startDate);

        insert testStm;
        return testStm;

    }

    public static Map<String,SObject> createSingleTestResource(){

        String objectName = '';
        Map<String, SObject> testResourceObjectMap = new Map<String, SObject>();
        String userId = UserInfo.getUserId();
        String testName = 'test' + String.valueOf(Crypto.getRandomInteger());

        WorkType testWorkType = createWorkType(testName, 1, 'hours');
        objectName = 'WorkType';
        testResourceObjectMap.put(objectName, testWorkType);

        OperatingHours testOh = createOperatingHours(testName);
        objectName = 'OperatingHours';
        testResourceObjectMap.put(objectName, testOh);

        ServiceTerritory testTerritory = createServiceTerritory(testName, true, testOh.Id);
        objectName = 'ServiceTerritory';
        testResourceObjectMap.put(objectName, testTerritory);

        ServiceResource testResource = createServiceResource(testName, true, userId, 'T');
        objectName = 'ServiceResource';
        testResourceObjectMap.put(objectName, testResource);

        ServiceTerritoryMember testSTM = createServiceTerritoryMember(testResource.Id, testTerritory.Id, datetime.now());
        objectName = 'ServiceTerritoryMember';     
        testResourceObjectMap.put(objectName, testSTM);
        return testResourceObjectMap;

    }


    public static Map<String,SObject> createSingleTestResource(String userId){

        String objectName = '';
        Map<String, SObject> testResourceObjectMap = new Map<String, SObject>();
        String testName = 'test' + String.valueOf(Crypto.getRandomInteger());

        WorkType testWorkType = createWorkType(testName, 1, 'hours');
        objectName = 'WorkType';
        testResourceObjectMap.put(objectName, testWorkType);

        OperatingHours testOh = createOperatingHours(testName);
        objectName = 'OperatingHours';
        testResourceObjectMap.put(objectName, testOh);

        ServiceTerritory testTerritory = createServiceTerritory(testName, true, testOh.Id);
        objectName = 'ServiceTerritory';
        testResourceObjectMap.put(objectName, testTerritory);

        ServiceResource testResource = createServiceResource(testName, true, userId, 'T');
        objectName = 'ServiceResource';
        testResourceObjectMap.put(objectName, testResource);

        ServiceTerritoryMember testSTM = createServiceTerritoryMember(testResource.Id, testTerritory.Id, datetime.now());
        objectName = 'ServiceTerritoryMember';        
        testResourceObjectMap.put(objectName, testSTM);

        return testResourceObjectMap;

    }


    public static WorkOrder createWorkOrder(){

        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;
        Skill testSkill = [SELECT Id FROM Skill LIMIT 1];
        SkillRequirement woSkill = new SkillRequirement(RelatedRecordId = testWorkOrder.Id, SkillId = testSkill.Id, SkillLevel=1);
        insert woSkill;
        return testWorkOrder;

    }


    public static WorkOrder createWorkOrder(String subject, String workTypeId, String serviceTerritoryId){

        WorkOrder testWorkOrder = new WorkOrder(Subject = subject,
                                                WorkTypeId = workTypeId,
                                                ServiceTerritoryId = serviceTerritoryId);

        insert testWorkOrder;
        return testWorkOrder;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(MR_Service_Resource__c = mrServiceResourceID,
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd, String status){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(MR_Service_Resource__c = mrServiceResourceID,
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd,
                                                                           Status = status);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ServiceAppointment createServiceAppointment(String mrServiceResourceID, String parentRecordId, Datetime earlyStart, Datetime dueDate, Datetime schedStart, Datetime schedEnd, String status, String territoryId){

        ServiceAppointment testServiceAppointment = new ServiceAppointment(MR_Service_Resource__c = mrServiceResourceID,
                                                                           ParentRecordId = parentRecordId,
                                                                           EarliestStartTime = earlyStart,
                                                                           DueDate = dueDate,
                                                                           SchedStartTime = schedStart,
                                                                           SchedEndTime = schedEnd,
                                                                           Status = status,
                                                                           ServiceTerritoryId = territoryId);
        
        insert testServiceAppointment;
        return testServiceAppointment;

    }


    public static ResourceAbsence createResourceAbsence(String resourceId, Datetime startDate, Datetime endDate){

        final Id NONAVAILABILITY_RECORDTYPE = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
        ResourceAbsence testAbsence = new ResourceAbsence(ResourceId = resourceId,
                                                           Start = startDate,
                                                           End = endDate,
                                                           RecordTypeId = NONAVAILABILITY_RECORDTYPE);

        insert testAbsence;
        return testAbsence;

    }


    public static AssignedResource createAssignedResource(String serviceAppointmentId, String serviceResourceId){

        AssignedResource testAssignedResource = new AssignedResource(ServiceResourceId = serviceResourceId, 
                                                                     ServiceAppointmentId = serviceAppointmentId);

        insert testAssignedResource;
        return testAssignedResource;

    }


    public static List<User> createUser(Integer numberOfUsersToCreate){

        List<User> testUserList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Integer i = 0;

        while(i < numberOfUsersToCreate){

            User u = new User(Alias = 'standt' + i, 
                          Email='standarduser' + i + '@example.com', 
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser' + i + '@MRDTReassignTechs.com');

            testUserList.add(u);

            i++;

        }

        insert testUserList;
        return testUserList;

    }


    public static ServiceResourceSkill createServiceResourceSkill(String serviceResourceId){

        Skill testSkill = [SELECT Id FROM Skill LIMIT 1];

        ServiceResourceSkill resourceSkill = new ServiceResourceSkill(ServiceResourceId = serviceResourceId, SkillId = testSkill.Id, EffectiveStartDate = Datetime.now().addDays(-10),SkillLevel=1);
        insert resourceSkill;
        return resourceSkill;

    }


}