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
    //set of skill levels matched and not matched for WO
    public woSkillProfile thisWoSkillProfile = new woSkillProfile();
    //main class
    public MRDTSkillMatcher(map<id,Decimal> mapSkillsNeeded,set<string> setResourceId,datetime startDateTime,datetime endDateTime) {
        //loop through all of the resources and initialize the match skills to blanks   
        if(Schema.sObjectType.skill.isQueryable()&& Schema.sObjectType.ServiceResourceSkill.isQueryable()) 
            try{
                for(id thisResourceId : setResourceId) {
                    resourceProfile rP = new resourceProfile();
                    rP.skillsMatched='';
                    rP.skillLevelsMatched='';
                    rP.skillNamesMatched='';
                    rP.skillCounter=0;
                    mapSRSkillProfile.put(thisResourceId,rP);
                }
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
                        // if(mapSkillsNeeded.get(thisSRS.SkillId)==null){
                        //     if(rP.skillsMatched!='')
                        //         rP.skillsMatched+=',';
                        //     rP.skillsMatched=rP.skillsMatched+mapSkillNames.get(thisSRS.SkillId)+'-'+skillDisplay;
                        //     rp.skillCounter++;
                        // }
                        system.debug('****** srs ' + thisSRS.skilllevel + ' *** mapskills ' + mapSkillsNeeded.get(thisSRS.SkillId));
                        if(mapSkillsNeeded.get(thisSRS.SkillId)==-1 || (mapSkillsNeeded.get(thisSRS.SkillId)!=null && (thisSRS.SkillLevel != null && thisSRS.SkillLevel>= mapSkillsNeeded.get(thisSRS.SkillId))) ){
                            if(rP.skillsMatched!='')
                                rP.skillsMatched+=',';
                            rP.skillsMatched=rP.skillsMatched+mapSkillNames.get(thisSRS.SkillId)+'-'+skillDisplay;
                            rP.setSkillLevelsMatched.add(thisSRS.SkillId);
                            rP.skillCounter++;
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
                    //build the summary list of skills matched for the WO and not matched
                    //initialize sets to the wo skills required
                    for(id thisSkillId : mapSkillsNeeded.keySet()) {
                        thisWoSkillProfile.setSkillLevelsMatched.add(thisSkillId);
                        thisWoSkillProfile.setSkillLevelsNotMatched.add(thisSkillId);
                    }
                    //loop through all of the resources and remove matched skills from the WO not matched set
                    for(id thisSRId : mapSRSkillProfile.keySet()) {
                        if(thisWoSkillProfile.setSkillLevelsNotMatched.size()>0) 
                            thisWoSkillProfile.setSkillLevelsNotMatched.removeAll(mapSRSkillProfile.get(thisSRId).setSkillLevelsMatched);
                    }
                    //if there are WO skills not matched, remove them from the list of WO skills matched
                    if(thisWoSkillProfile.setSkillLevelsNotMatched.size()>0) thisWoSkillProfile.setSkillLevelsMatched.removeAll(thisWoSkillProfile.setSkillLevelsNotMatched);
                    //build the WO skills matched string
                    for(id thisSkillId: thisWoSkillProfile.setSkillLevelsMatched){
                        if(thisWoSkillProfile.skillsMatched!='') thisWoSkillProfile.skillsMatched+=', ';
                        thisWoSkillProfile.skillsMatched+=mapSkillNames.get(thisSkillId);
                    }
                    //build the WO skills not matched string
                    for(id thisSkillId: thisWoSkillProfile.setSkillLevelsNotMatched){
                        if(thisWoSkillProfile.skillsNotMatched!='') thisWoSkillProfile.skillsNotMatched+=', ';
                        //since -1 represents a blank skill level, convert it back to a 0 for the display
                        if(mapSkillsNeeded.get(thisSkillId)==-1) 
                            thisWoSkillProfile.skillsNotMatched+=mapSkillNames.get(thisSkillId)+'-0';
                        else        
                        thisWoSkillProfile.skillsNotMatched+=mapSkillNames.get(thisSkillId)+'-'+mapSkillsNeeded.get(thisSkillId).format();
                        
                    }
                }
            }
            catch(Exception e) {
                //the empty map will be returned
                system.debug('*****exceptiono info ' + mapSkillsNeeded);
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
        //list of skill ids matched
        public set<id> setSkillLevelsMatched;

        public resourceProfile(){
            skillsMatched='';
            skillLevelsMatched='';
            skillNamesMatched='';
            skillCounter=0;
            setSkillLevelsMatched=new set<id>();
        }
    }
    Public Class woSkillProfile {
        //stores list of skill and level matched
        public string skillsMatched='';
        //list of skill ids matched
        public set<id> setSkillLevelsMatched;
        //stores list of skill and level not matched
        public string skillsNotMatched='';
        //list of skill ids not matched
        public set<id> setSkillLevelsNotMatched;

        public woSkillProfile(){
            skillsMatched='';
            setSkillLevelsMatched=new set<id>();
            skillsNotMatched='';
            setSkillLevelsNotMatched=new set<id>();
        }
    }
}