//MRDTSkillMatcher Author: Chris Albanese, Version 1, Created Oct 31, 2022
//Purpose: determine how well a resource's skill matches the required skills
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
public with sharing class MRDTSkillMatcher {

    //this is the list of resource ids along with a string containing a list of the matched skills and levels
    public map<id,resourceProfile> mapSRSkillProfile = new map<id,resourceProfile>();
    //simple list of skill ids and names
    public map<id,string> mapSkillNames = new map<id,string>();
    //main class
    public MRDTSkillMatcher(map<id,Decimal> mapSkillsNeeded,set<string> setResourceId,datetime startDateTime,datetime endDateTime) {
        //loop through all of the resources and initialize the match skills to blanks
        system.debug('******************** parameter info: mapSkillsNeeded size = ' + mapSkillsNeeded.size());
        system.debug('******************** parameter info: setResourceId size = ' + setResourceId.size());
        system.debug('******************** parameter info: start date = ' + startDateTime);
        system.debug('******************** parameter info: end date = ' + endDateTime);       
        if(Schema.sObjectType.skill.isQueryable()&& Schema.sObjectType.ServiceResourceSkill.isQueryable()) 
            try{
                for(id thisResourceId : setResourceId) {
                    resourceProfile rP = new resourceProfile();
                    rP.skillsMatched='';
                    rP.skillLevelsMatched='';
                    rP.skillNamesMatched='';
                    rP.skillCounter=0;
                    system.debug('********** rp = '+rP);
                    system.debug('********** thisResourceId = '+thisResourceId);
                    mapSRSkillProfile.put(thisResourceId,rP);
                }
                system.debug('******* mapSRSkillProfile size = ' + mapSRSkillProfile.size());
                //if we don't need any skills then no need to process anything
                if(mapSkillsNeeded!=null) {
                    //build the list of skill ids and names and put them in a map
                    list<Skill> listSkill = new list<skill>(
                        [select 
                        Id, 
                        MasterLabel 
                        from Skill 
                        where 
                        id in :mapSkillsNeeded.keySet()]);
                    for(Skill thisSkill: listSkill) mapSkillNames.put(thisSkill.Id,thisSkill.MasterLabel);
                    system.debug('****** skill name size ' + mapSkillNames.size());
                    //find the list of skills that each resource has regardless of skill level
                    list<ServiceResourceSkill> listSRSkills = new List<ServiceResourceSkill>();
                    listSRSkills = [select 
                        Id,
                        SkillId,
                        ServiceResourceId,
                        SkillLevel 
                        from ServiceResourceSkill 
                        where 
                        ServiceResourceId in :setResourceId and 
                        SkillId in :mapSkillsNeeded.keySet() and 
                        ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))];
                    //loop through each skill each resource has and build resource skill profile
                    for(ServiceResourceSkill thisSRS : listSRSkills){
                        string skillDisplay='';
                        if(thisSRS.SkillLevel!=null)
                            skillDisplay=thisSRS.SkillLevel.format();
                        resourceProfile rP = mapSRSkillProfile.get(thisSRS.ServiceResourceId);
                        //if the skill and the level match then add this skill to skillsMatched and increment skill counter
                        if(mapSkillsNeeded.get(thisSRS.SkillId)==null && thisSRS.skillLevel==null){
                            if(rP.skillsMatched!='')
                                rP.skillsMatched+=',';
                            rP.skillsMatched=rP.skillsMatched+mapSkillNames.get(thisSRS.SkillId)+'-'+skillDisplay;
                            rp.skillCounter++;
                        }
                        if( mapSkillsNeeded.get(thisSRS.SkillId)==null || (thisSRS.SkillLevel != null && thisSRS.SkillLevel>= mapSkillsNeeded.get(thisSRS.SkillId)) ){
                            if(rP.skillsMatched!='')
                                rP.skillsMatched+=',';
                            rP.skillsMatched=rP.skillsMatched+mapSkillNames.get(thisSRS.SkillId)+'-'+skillDisplay;
                            rp.skillCounter++;
                        }
                        //add this skill to skillNamesMatched - remember we don't care about skill levels for this field
                        if(rP.skillNamesMatched!='')
                            rP.skillNamesMatched+=',';
                        rP.skillNamesMatched=rP.skillNamesMatched+mapSkillNames.get(thisSRS.SkillId)+'-'+skillDisplay;               
                        mapSRSkillProfile.put(thisSRS.ServiceResourceId,rP);
                    }
                    //loop through the finished map to write the skillLevelsMatched
                    for(id thisId : mapSRSkillProfile.keySet()) {
                        resourceProfile rP = mapSRSkillProfile.get(thisId); 
                        rP.skillLevelsMatched = rP.skillCounter.format()+'/'+mapSkillsNeeded.size();
                        mapSRSkillProfile.put(thisId,rP);
                    }
                }
            }
            catch(Exception e) {
                //the empty map will be returned
            }
    }

    Public Class resourceProfile {
        //stores list of skill and level matched
        public string skillsMatched='';
        //stores counter information such as 3/5 skills matched
        public string skillLevelsMatched='';
        //stores list of skills matched ignoring skill level
        public string skillNamesMatched='';
        //stores total number of skill and level matched. used to set value for skillLevelsMatched
        public Decimal skillCounter=0;

        public resourceProfile(){
            skillsMatched='';
            skillLevelsMatched='';
            skillNamesMatched='';
            skillCounter=0;
        }
    }

}
