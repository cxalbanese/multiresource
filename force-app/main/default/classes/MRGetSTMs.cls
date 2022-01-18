public class MRGetSTMs {
// this returns a list of Service Resource Id given a Service Territory or All Territories and a Skill or All Skills
@invocableMethod(label='MR Get STM records')
public static list<list<string>> GetSTMS (list<inPayLoad> listPayload) {
    String territoryId = listPayload[0].inTerritoryId;
    String skillId = listPayload[0].inSkillId;
    list<serviceterritory> listST = new list<serviceterritory>();
    list<serviceterritorymember> listSTM = new list<serviceterritorymember>();
    list<serviceresourceskill> listSRSkill = new list<serviceresourceskill>();
    list<string> listSRId = new list<string>();
    set<string> setSRId = new set<string>();
    //if its all territories just find all Active STs
    if(territoryId == 'All') 
       listST = [select id from serviceterritory where isactive = true];
       //else just get the specified territory
       else
           listST = [select id from serviceterritory where id = :territoryId];
    //Get all STMs from ListST and add them to the set
    listSTM = [select ServiceResourceId from ServiceTerritoryMember where serviceterritoryid in :listST];
    for(ServiceTerritoryMember stm :listSTM) setSRId.add(stm.ServiceResourceId);
    //if all skills then just use the list of STM.ServiceResourceIds else filter out only the resources who have the skill
    if(skillId <> 'All') {
        listSRSkill = [select id,ServiceResourceId from ServiceResourceSkill where ServiceResourceId in :setSRId and SkillId = :skillId];
        for(ServiceResourceSkill srs : listSRSkill) listSRId.add(srs.ServiceResourceId);
    }
    else listSRId = new list<String>(setSRId); 
    
   
return new list<list<string>>{listSRId};

}

public class inPayLoad{
@invocableVariable
public string inTerritoryId;
@invocableVariable
public string inSkillId;
}

}