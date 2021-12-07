Public Class SchedMultiVisit {


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
    id SchedMultiBatchId = Database.executeBatch(new SchedMultiVisitBatch(myPayload));
    
 /*   list<string> resourceIdList = inPayloadList[0].resourceIds;
    inPayload iPL = inPayloadList[0];
    integer numWeeks = iPL.numweeks;
    string territoryid = iPL.territoryid;
    string workorderid = iPL.workorderid;
    date starting = iPL.starting;
    date until = iPL.until;
    string mystring = '';
    list<string> stringList = new list<string>();
    for(string thestring : resourceIdList) mystring+= thestring + ' - ';
    stringList.add(mystring);
    
    list<integer> selecteddays = new list<integer>(); 
	if(iPL.dow.containsIgnoreCase('Sunday')) selecteddays.add(0);
	if(iPL.dow.containsIgnoreCase('Monday')) selecteddays.add(1);
	if(iPL.dow.containsIgnoreCase('Tuesday')) selecteddays.add(2);
	if(iPL.dow.containsIgnoreCase('Wednesday')) selecteddays.add(3);
	if(iPL.dow.containsIgnoreCase('Thursday')) selecteddays.add(4);
	if(iPL.dow.containsIgnoreCase('Friday')) selecteddays.add(5);
	if(iPL.dow.containsIgnoreCase('Saturday')) selecteddays.add(6);
    
    list<serviceappointment> newSAs = new list<serviceappointment>();
    list<assignedresource> newARs = new list<assignedresource>();
    integer duration = 8;
    workorder thewo = [select id, subject, city, state, street, postalcode from workorder where id =: workorderid limit 1];
    
    for (string theResourceId : resourceIdList) {
    
        for (integer thedayofweek : selecteddays ) {
        
            serviceappointment thesa = new serviceappointment();
            thesa.parentrecordid = workorderid;
            thesa.serviceterritoryid = territoryid;
            thesa.durationtype = 'hours';
            thesa.duration = duration;
            thesa.earlieststarttime = datetime.newinstance(starting.adddays(thedayofweek).year(),starting.adddays(thedayofweek).month(),starting.adddays(thedayofweek).day()).addhours(8);
            thesa.duedate = thesa.earlieststarttime.adddays(1).addminutes(-1);
            thesa.schedstarttime = thesa.earlieststarttime;
            thesa.schedendtime = thesa.schedstarttime.addhours(8);
            thesa.Parent_Work_Order__c = workorderid;
            thesa.FSL__GanttLabel__c = thewo.subject;
            thesa.city = thewo.city;
            thesa.street = thewo.street;
            thesa.state = thewo.state;
            thesa.postalcode = thewo.postalcode;
            thesa.FSLDemoTools_Service_Resource__c = theResourceId.trim();
            thesa.Status = 'Scheduled';
            thesa.subject = '01 Upgrade Generator Control';
            newSAs.add (thesa);
              
        }
   }
       if(newSAs.size()>0) {
           insert newSAs;  
           for(serviceappointment thesa : newSAs) {
              assignedresource ar = new assignedresource();
              ar.serviceappointmentid = thesa.id;
              ar.serviceresourceid = thesa.FSLDemoTools_Service_Resource__c;
              newARs.add(ar);
           }   
           if (newARs.size()>0) insert newARs; 
       }
          
    
    
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    return stringList;
*/
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