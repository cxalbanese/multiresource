Public Class MRSchedMultiVisit {


@invocablemethod
public static list<string> ScheduleThem (list<inPayload> inPayloadList) {
    WOSchedulePayload myPayload = new WOSchedulePayload();
    myPayload.dow = inPayloadList[0].dow;
    myPayload.numWeeks = 0;
    myPayload.starting = inPayloadList[0].starting;
    myPayload.until = inPayloadList[0].until;
    myPayload.status = inPayloadList[0].status;
    myPayload.taskDescription = inPayloadList[0].taskDescription;
    myPayload.territoryId = inPayloadList[0].territoryId;
    myPayload.workorderid = inPayloadList[0].workorderid;
    myPayload.resourceIds = inPayloadList[0].resourceIds;
    myPayload.startTimeTextList = inPayloadList[0].startTimeTextList;
    myPayload.durationList = inPayloadList[0].durationList;
    system.debug(inPayloadList[0].resourceIds);
    system.debug(myPayload.resourceIds);
    id SchedMultiBatchId = Database.executeBatch(new MRSchedMultiVisitBatch(myPayload));
    
    return new list<string>{'all set'};
}




public class inPayload {
@invocablevariable
public list<string> resourceIds;
@invocablevariable
public string territoryId;
@invocablevariable
public integer numWeeks;
@invocablevariable
public boolean SundayChecked; 
@invocablevariable
public boolean MondayChecked;
@invocablevariable
public boolean TuesdayChecked;
@invocablevariable
public boolean WednesdayChecked;
@invocablevariable
public boolean ThursdayChecked;
@invocablevariable
public boolean FridayChecked;
@invocablevariable
public boolean SaturdayChecked;
@invocablevariable
public string workorderid;
@invocablevariable
public date starting;
@invocablevariable
public date until;
@invocablevariable
public string dow;
@invocablevariable
public list<string> startTimeTextList;    
@invocablevariable
public list<integer> durationList; 
@invocablevariable
public string status; 
@invocablevariable
public string taskDescription;    
}
}