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

        WorkType testWorkType = createWorkType('test', 1, 'hours');
        objectName = 'WorkType';
        testResourceObjectMap.put(objectName, testWorkType);

        OperatingHours testOh = createOperatingHours('test');
        objectName = 'OperatingHours';
        testResourceObjectMap.put(objectName, testOh);

        ServiceTerritory testTerritory = createServiceTerritory('test', true, testOh.Id);
        objectName = 'ServiceTerritory';
        testResourceObjectMap.put(objectName, testTerritory);

        ServiceResource testResource = createServiceResource('test', true, userId, 'T');
        objectName = 'ServiceResource';
        testResourceObjectMap.put(objectName, testResource);

        ServiceTerritoryMember stm = createServiceTerritoryMember(testResource.Id, testTerritory.Id, datetime.now());
        objectName = 'ServiceTerritoryMember';

        return testResourceObjectMap;

    }


    public static WorkOrder createWorkOrder(){

        WorkOrder testWorkOrder = new WorkOrder();
        insert testWorkOrder;
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


}
