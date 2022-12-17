//MRDTSchedMultiVisit Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Create draft SAs for the selected STMs and date range specified
//Called by: Flow: MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
//Change Log:
//May 16, 2022 - added country to line 62 soql query and added line 86 to update sa.country with this value
public With Sharing class MRDTSchedMultiVisit {

@invocableMethod (label='MR DT Create Multiple Visits')
public static list<WODTScheduleOutput> MRDTMV (list<WODTSchedulePayload> inPayloadList) {

    WODTSchedulePayload iPL = inPayloadList[0];
    list<serviceterritorymember> listSTM = iPL.listSTM;
    boolean includeWeekendDay1 = iPL.includeWeekendDay1;
    boolean includeWeekendDay2 = iPL.includeWeekendDay2;
    boolean includeOnlyWeekends = iPL.includeOnlyWeekends;
    string weekendDay1 = 'Sat';
    string weekendDay2 = 'Sun';
    integer limitSAs = iPL.limitSAs;
    string territoryid = iPL.territoryid;
    string workorderid = iPL.workorderid;
    string status = iPL.status;
    string taskDescription = iPL.taskDescription;
    date starting = iPL.starting;
    date until = iPL.until;
    Datetime startDateTime =  datetime.newinstance(iPL.starting.year(),iPL.starting.month(),iPL.starting.day());
    Datetime endDateTime = datetime.newinstance(iPL.until.year(),iPL.until.month(),iPL.until.day()).adddays(1);
    string startTime = iPL.startTime;
    integer duration = iPL.defaultDuration;  
    string overlapResultsJSON = iPL.overlapResultsJSON;
    Set<String> setSRId = new Set<String>();
    map<id,decimal> mapSkillsRequired = new map<id,decimal>();
    list<SkillRequirement> skillList = new List<SkillRequirement>();
    map<id,MRDTSkillMatcher.resourceProfile> mapResourceProfile = new map<id,MRDTSkillMatcher.resourceProfile>(); 
    MRDTSkillMatcher.woSkillProfile woSkillProfile = new MRDTSkillMatcher.woSkillProfile();
    set<string> setWeekdays = new set<string>{'Mon','Tue','Wed','Thu','Fri'};
    if(duration < 0 || duration > 18) duration = 8;

    string mystring = '';
    list<date> listDate = new list<date>();
    for(integer x = 0;x < starting.daysBetween(until)+1;x++) {listDate.add(starting.adddays(x));}

    //for loop does basic data validation since my lightning component doesn't validate everything                       
    integer startTimeHour = 9;
    integer startTimeMinute = 0;      
        if(startTime.length() == 8) {
          string h = startTime.substring(0,2);
          string m = startTime.substring(3,5);
          string a = startTime.substring(6,8);
            if(h.isNumeric() && integer.valueof(h) <=12 && integer.valueof(h) >=0 ) {
              startTimeHour = integer.valueof(h);
              if(m.isNumeric() && integer.valueof(m) <=59 && integer.valueof(m) >=0 ) {
                    startTimeMinute = integer.valueof(m);
                    if(a.toUpperCase() == 'PM') startTimeHour+=12; 
                }
            }          
        }

    if (status == null)  status = 'Scheduled'; 

    //deserialize the JSON string passed in that contains the overlaps and store in a map
    map<string,MRDTresourceOverlaps> mapOverlaps = new map<string,MRDTresourceOverlaps>();
    if(!(overlapResultsJSON==null || overlapResultsJSON==''))
        mapOverlaps=(map<string,MRDTresourceOverlaps>)json.deserialize(overlapResultsJSON,map<string,MRDTresourceOverlaps>.class);
                               
    list<serviceappointment> listNewSAs = new list<serviceappointment>();
    list<serviceappointment> listSavedSAs = new list<serviceappointment>();
    list<assignedresource> newARs = new list<assignedresource>();
    WODTScheduleOutput saOutput = new WODTScheduleOutput();
    saOutput.listSA = new list<serviceappointment>();
    saOutput.numSAs = 0;
    WorkOrder thewo = new WorkOrder();
    try{
        if(Schema.SObjectType.WorkOrder.isQueryable())
            thewo = [select 
                        id, 
                        subject, 
                        city, 
                        state, 
                        street, 
                        postalcode,
                        country 
                    from workorder 
                        where id =: workorderid limit 1];
        if(taskDescription == null ) taskDescription = thewo.subject;
        for(serviceterritorymember stm : listSTM) {
            string theResourceId = stm.serviceresourceid;    
            for (date thedate : listDate ) {
                datetime dowdatetime = datetime.newinstance(thedate.year(),thedate.month(),thedate.day());
                string dow = datetime.newinstance(thedate.year(),thedate.month(),thedate.day()).format('EEE');
                if((dow == weekendDay1 && includeWeekendDay1) || 
                    (dow == weekendDay2 && includeWeekendDay2) || 
                    (dow != weekendDay1 && dow != weekendDay2 && !includeOnlyWeekends)) {
                    serviceappointment thesa = new serviceappointment();            
                    thesa.parentrecordid = workorderid;
                    //thesa.serviceterritoryid = territoryid;
                    thesa.durationtype = 'hours';
                    thesa.duration = duration;
                    thesa.earlieststarttime = datetime.newinstance(thedate.year(),thedate.month(),thedate.day(),startTimeHour,startTimeMinute,0);
                    thesa.duedate = thesa.earlieststarttime.adddays(1).addminutes(-1);
                    thesa.schedstarttime = thesa.earlieststarttime;
                    thesa.schedendtime = thesa.schedstarttime.addhours(duration);
                    thesa.MR_Parent_Work_Order__c = workorderid;
                    thesa.FSL__GanttLabel__c = thewo.subject;
                    thesa.city = thewo.city;
                    thesa.street = thewo.street;
                    thesa.state = thewo.state;
                    thesa.postalcode = thewo.postalcode;
                    thesa.country = thewo.country;
                    thesa.MR_Service_Resource__c = theResourceId.trim();
                    thesa.Status = status;
                    thesa.subject = taskDescription;
                    thesa.MR_Creation_Status__c = 'Draft';
                    //if there's a conflict for this Resource for this date, write it to the new SA
                    if(mapOverlaps.containsKey(thesa.MR_Service_Resource__c)) {
                        thesa.MR_DT_Skill_Levels_Matched__c = mapOverlaps.get(thesa.MR_Service_Resource__c).skillLevelsMatched;
                        thesa.MR_DT_Skill_Names_Matched__c = mapOverlaps.get(thesa.MR_Service_Resource__c).skillNamesMatched;
                        thesa.MR_DT_Skills_Matched__c = mapOverlaps.get(thesa.MR_Service_Resource__c).skillsMatched;
                        map<date,MRDTresourceOverlaps.saConflictDetails> mapDateOverlap = mapOverlaps.get(thesa.MR_Service_Resource__c).mapSAConflictDetails;
                        if(mapDateOverlap.containsKey(theDate)) {
                            //this is the text field containing the list of SAs and RAs that are in conflict
                            thesa.MR_DT_Conflict_Details__c = mapDateOverlap.get(theDate).conflictDetails.trim();
                            if(thesa.Duration!=0)
                                //this is the sum of those SAs and RAs in conflict/current SA duration
                                thesa.MR_DT_Percent_Availability__c = math.max(0,((1- (mapDateOverlap.get(theDate).blockedHours / thesa.Duration))*100)).format(); 
                        }
                    }
                        
                    listNewSAs.add (thesa);
                }  
            }
        }       

       if(Schema.sObjectType.serviceappointment.isCreateable() && listNewSAs.size()>0 && listNewSAs.size()<= limitSAs) {
           insert listNewSAs;  
           if(Schema.sObjectType.serviceappointment.isQueryable())
                for(serviceappointment sa: 
                        [select 
                            appointmentnumber, 
                            parentrecordid,
                            serviceterritoryid,
                            durationtype,
                            duration,
                            earlieststarttime,
                            duedate,
                            schedstarttime,
                            schedendtime,
                            mr_parent_work_order__c,
                            fsl__ganttlabel__c,
                            city,
                            street,
                            postalcode,
                            mr_service_resource__c,
                            status,
                            mr_creation_status__c,
                            mr_dt_conflict_details__c,
                            mr_dt_percent_availability__c,
                            mr_dt_skill_levels_matched__c,
                            mr_dt_skill_names_matched__c,
                            mr_dt_skills_matched__c
                        from serviceappointment 
                            where 
                                id in :listNewSAs])
                    listSavedSAs.add(sa);
            //this next set of code builds the list of missing skills for the WO
            //build a set of selected Service Resource Ids
            for(ServiceTerritoryMember stm :listSTM) {
                setSRId.add(stm.ServiceResourceId);
            }
            //get the list of skills requried for the work order
            if(Schema.SObjectType.WorkOrder.isQueryable() && 
                Schema.SObjectType.SkillRequirement.isQueryable()) {
                skillList = [select id,skillid,skilllevel from SkillRequirement where RelatedRecordId=:workorderid];
                //convert null skill levels to -1 since we can't pass null inside of a map to another method
                for(SkillRequirement sR : skillList) {
                    if(sr.SkillLevel!=null)
                        mapSkillsRequired.put(sR.skillid,sR.skilllevel);
                    else 
                        mapSkillsRequired.put(sR.SkillId,-1);
                }
            }   
            //if skills are required on the WO, let's calculate the missing skills
            If(mapSkillsRequired.size()> 0) {    
                MRDTSkillMatcher skillMatcher = new MRDTSkillMatcher(mapSkillsRequired,setSRId,startDateTime,endDateTime);
                mapResourceProfile = skillMatcher.mapSRSkillProfile;
                woSkillProfile = skillMatcher.thisWoSkillProfile;                
            }
            saOutput.listSA = new list<serviceappointment>(listSavedSAs);
            saOutput.numSAs = listNewSAs.size();
            saOutput.woSkillNamesMatched = woSkillProfile.skillsMatched;
            saOutput.woSkillNamesNotMatched = woSkillProfile.skillsNotMatched;
            return new list<WODTScheduleOutput>{saOutput};
           }
       if(listNewSAs.size()>limitSAs) {
           return new list<WODTScheduleOutput>{saOutput};
           }
       return new list<WODTScheduleOutput>{saOutput};
      }
      catch(exception e) {
       return new list<WODTScheduleOutput>{saOutput};
      }                    
  }


public class WODTSchedulePayload {
  
@invocableVariable public list<serviceterritorymember> listSTM;
@invocableVariable public string territoryId;
@invocableVariable public string workorderid;
@invocableVariable public date starting;
@invocableVariable public date until;
@invocableVariable public string startTime;
@invocableVariable public integer defaultDuration;
@invocableVariable public string status;
@invocableVariable public string taskDescription;
@invocableVariable public integer limitSAs;
@invocableVariable public boolean includeWeekendDay1;
@invocableVariable public boolean includeWeekendDay2;
@invocableVariable public boolean includeOnlyWeekends;
@invocableVariable public string overlapResultsJSON;

}

public class WODTScheduleOutput {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public integer numSAs;
@invocableVariable public string woSkillNamesMatched;
@invocableVariable public string woSkillNamesNotMatched;}
}