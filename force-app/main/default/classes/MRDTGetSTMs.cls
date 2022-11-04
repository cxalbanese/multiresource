//MRDTGetSTMs Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: get a list of active service territory member records for the selected territory and skill
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public With Sharing class MRDTGetSTMs {
    
    // this returns a list of Service Resource Id given a Service Territory or All Territories and a Skill or All Skills
    @invocableMethod(label='MR DT Get STM records')
    public static list<outPayLoad> GetSTMS (list<inPayLoad> listPayload) {

        String territoryId = listPayload[0].inTerritoryId;
        String woId = listPayload[0].inWoId;
        String skillId = listPayload[0].inSkillId;
        Datetime startDateTime =  datetime.newinstance(listPayload[0].startDate.year(),listPayload[0].startDate.month(),listPayload[0].startDate.day());
        Datetime endDateTime = datetime.newinstance(listPayload[0].endDate.year(),listPayload[0].endDate.month(),listPayload[0].endDate.day()).adddays(1);
        List<ServiceTerritory> listST = new List<ServiceTerritory>();
        List<ServiceTerritoryMember> listSTM = new List<ServiceTerritoryMember>();
        List<ServiceTerritoryMember> listSTMFiltered = new List<ServiceTerritoryMember>();
        List<ServiceResourceSkill> listSRSkill = new List<ServiceResourceSkill>();
        List<String> listSRId = new List<String>();
        Set<String> setSRId = new Set<String>();
        map<id,decimal> mapSkillsRequired = new map<id,decimal>();
        list<SkillRequirement> skillList = new List<SkillRequirement>();
        map<id,MRDTSkillMatcher.resourceProfile> mapResourceProfile = new map<id,MRDTSkillMatcher.resourceProfile>();

       
        try{
            if(Schema.SObjectType.WorkOrder.isQueryable() && 
                Schema.SObjectType.SkillRequirement.isQueryable()) {
                skillList = [select id,skillid,skilllevel from SkillRequirement where RelatedRecordId=:woId];
                for(SkillRequirement sR : skillList) mapSkillsRequired.put(sR.skillid,sR.skilllevel);
            }
            if(Schema.sObjectType.serviceterritory.isQueryable())
                if(territoryId == 'All') {
                    //if its all territories just find all Active STs
                    listST = [select id from serviceterritory where isactive = true];
                }            
                else{ 
                    //else just get the specified territory
                    listST = [select id from serviceterritory where id = :territoryId];
                }
                
            //Get all effective STMs from ListST and add them to the set
            if(Schema.sObjectType.serviceterritorymember.isQueryable()) 
                listSTM = [SELECT 
                        EffectiveEndDate,
                        EffectiveStartDate,
                        Id,
                        MemberNumber,
                        ServiceResourceId,
                        ServiceTerritoryId,
                        MR_Resource_Name__c,
                        MR_Service_Territory__c, 
                        MR_DT_Overlap__c,
                        MR_DT_Skill_Levels_Matched__c,
                        MR_DT_Skill_Names_Matched__c,
                        MR_DT_Skills_Matched__c,
                        TerritoryType 
                        FROM ServiceTerritoryMember 
                        WHERE ServiceTerritoryId in :listST 
                        AND ((EffectiveStartDate <= :startDateTime AND EffectiveEndDate = null) OR (EffectiveStartDate <= :startDateTime AND EffectiveEndDate >= :endDateTime))];

            for(ServiceTerritoryMember stm :listSTM) {

                setSRId.add(stm.ServiceResourceId);

            }

            //if all skills then just use the list of STM.ServiceResourceIds else filter out only the resources who have the effective skill
            if(Schema.sObjectType.ServiceResourceSkill.isQueryable() && skillId != 'All') {

                listSRSkill = [select id,ServiceResourceId from ServiceResourceSkill where ServiceResourceId in :setSRId and SkillId = :skillId and ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))];
                
                for(ServiceResourceSkill srs : listSRSkill) {

                    listSRId.add(srs.ServiceResourceId);

                }

                for(ServiceTerritoryMember stm : listSTM) {

                    if(listSRID.contains(stm.ServiceResourceId)){

                        listSTMFiltered.add(stm);

                    } 

                }
            }
            else {
                listSTMFiltered = new list<serviceterritorymember>(listSTM); 
            }

            //let's see if there are any resource absences for the resources during the selected period of time  
            Final Id nonAvailRecordTypeId = Schema.SObjectType.ResourceAbsence.getRecordTypeInfosByName().get('Non Availability').getRecordTypeId();
            list<resourceabsence> raList = new list<resourceabsence>();
            if(Schema.sObjectType.resourceabsence.isQueryable()) 
                raList = [select id,resourceId from resourceabsence where ResourceId in :setSRId and recordtypeid = :nonAvailRecordTypeId and start < :endDateTime and end > :startDateTime ];

            //let's see if there are any service appointments for the resources during the selected period of time      
            Map<id,string> mapResourceOverlap = new map<id,string>();

            for(resourceabsence ra : raList) {
                mapResourceOverlap.put(ra.resourceid,'RA');
            }
            list<assignedresource> arList = new list<assignedresource>();
            if(Schema.sObjectType.assignedresource.isQueryable())
                arList = [select id,
                serviceresourceid 
                from assignedresource 
                where 
                serviceresourceid in :setSRId and 
                serviceappointmentid in (
                    select id from serviceappointment 
                    where 
                        /* serviceterritoryid in :listST and ******* removed in case there are secondary territories */
                        statuscategory not in  ('Canceled','None') and 
                        schedstarttime < :endDateTime and schedendtime > :startDateTime) ];    
            
            for(assignedresource ar : arList) {

                if(mapResourceOverlap.containsKey(ar.serviceresourceid)) 
                    if (mapResourceOverlap.get(ar.serviceresourceid) == 'RA' || mapResourceOverlap.get(ar.serviceresourceid) == 'Both') 
                        mapResourceOverlap.put(ar.serviceresourceid,'Both'); 
                    else mapResourceOverlap.put(ar.serviceresourceid,'SA');
                else mapResourceOverlap.put(ar.serviceresourceid,'SA');

            }

            if(mapResourceOverlap.size()>0){

                for(serviceterritorymember stm : listSTMFiltered) {

                    if(mapResourceOverlap.containsKey(stm.serviceresourceid)) {
                        stm.MR_DT_Overlap__c = mapResourceOverlap.get(stm.serviceresourceid);
                    }

                }

            }
            //if skills are required on the WO, let's build out the skill matching profile for the techs
            If(mapSkillsRequired.size()> 0 && setSRId.size()>0) {
                //this class determines the skill matching profile for the tech
                MRDTSkillMatcher skillMatcher = new MRDTSkillMatcher(mapSkillsRequired,setSRId,startDateTime,endDateTime);
                mapResourceProfile = skillMatcher.mapSRSkillProfile;
            } 
            if(mapResourceProfile.size()>0){
                //if we have a skill profile let's store in the STM. we don't perform DML on STM but we use
                //the fields on STM to temporarily hold the values so the datatable component in the flow can use it
                for(serviceterritorymember stm : listSTMFiltered) {

                    if(mapResourceProfile.containsKey(stm.serviceresourceid)) {
                        //MR_DT_Skill_Levels_Matched__c = # of skills/levels match = 3/5 for example
                        stm.MR_DT_Skill_Levels_Matched__c = mapResourceProfile.get(stm.serviceresourceid).skillLevelsMatched;
                        //MR_DT_Skill_Names_Matched__c = just list of skill names matched, regardless of level
                        stm.MR_DT_Skill_Names_Matched__c = mapResourceProfile.get(stm.serviceresourceid).skillNamesMatched;
                        //MR_DT_Skill_Matched__c = list of skill names/levels matched. i.e. if level doesn't match skill is not included here
                        stm.MR_DT_Skills_Matched__c = mapResourceProfile.get(stm.serviceresourceid).skillsMatched;
                    }

                }

            }       

            outPayLoad oPL = new outPayLoad();
            oPL.stmList = new list<serviceterritorymember>(listSTMFiltered);
            oPL.overlapWarning = mapResourceOverlap.size()>0 ? 'warning' : '';

            return new list<outPayLoad>{oPL};
        }
        catch(exception e) {
            return new list<outPayLoad>();
        }

    }


    public class inPayLoad{
        @invocableVariable
        public string inTerritoryId;
        @invocableVariable
        public string inSkillId;
        @invocableVariable
        public date startDate;
        @invocableVariable
        public date endDate;
        @invocableVariable
        public string inWoId;
    }


    public class outPayLoad{
        @invocableVariable
        public list<serviceterritorymember> stmList;
        @invocableVariable
        public string overlapWarning;
    }

}