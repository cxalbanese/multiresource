public class MRDTGetSTMs {
// this returns a list of Service Resource Id given a Service Territory or All Territories and a Skill or All Skills
@invocableMethod(label='MR DT Get STM records')
public static list<list<ServiceTerritoryMember>> GetSTMS (list<inPayLoad> listPayload) {
    String territoryId = listPayload[0].inTerritoryId;
    String skillId = listPayload[0].inSkillId;
    datetime startDateTime =  datetime.newinstance (listPayload[0].startDate.year(),listPayload[0].startDate.month(),listPayload[0].startDate.day());
    datetime endDateTime = datetime.newinstance(listPayload[0].endDate.year(),listPayload[0].endDate.month(),listPayload[0].endDate.day()).adddays(1);
    list<serviceterritory> listST = new list<serviceterritory>();
    list<serviceterritorymember> listSTM = new list<serviceterritorymember>();
    list<serviceterritorymember> listSTMFiltered = new list<serviceterritorymember>();
    list<serviceresourceskill> listSRSkill = new list<serviceresourceskill>();
    list<string> listSRId = new list<string>();
    set<string> setSRId = new set<string>();
    //if its all territories just find all Active STs
    if(territoryId == 'All') 
       listST = [select id from serviceterritory where isactive = true];
       //else just get the specified territory
       else
           listST = [select id from serviceterritory where id = :territoryId];
    //Get all effective STMs from ListST and add them to the set
    listSTM = [SELECT EffectiveEndDate,EffectiveStartDate,Id,MemberNumber,ServiceResourceId,ServiceTerritoryId,MR_Resource_Name__c,MR_Service_Territory__c,TerritoryType FROM ServiceTerritoryMember where serviceterritoryid in :listST and
    ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))];
    for(ServiceTerritoryMember stm :listSTM) setSRId.add(stm.ServiceResourceId);
    //if all skills then just use the list of STM.ServiceResourceIds else filter out only the resources who have the effective skill
    if(skillId <> 'All') {
        listSRSkill = [select id,ServiceResourceId from ServiceResourceSkill where ServiceResourceId in :setSRId and SkillId = :skillId and ((EffectiveStartDate <= :startDateTime and EffectiveEndDate = null) or (EffectiveStartDate <= :startDateTime and EffectiveEndDate >= :endDateTime))];
        for(ServiceResourceSkill srs : listSRSkill) listSRId.add(srs.ServiceResourceId);
        for(ServiceTerritoryMember stm : listSTM) if (listSRID.contains(stm.ServiceResourceId)) listSTMFiltered.add(stm);
    }
    else listSTMFiltered = new list<serviceterritorymember>(listSTM); 
    
   
return new list<list<ServiceTerritoryMember>>{listSTMFiltered};

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
}

}