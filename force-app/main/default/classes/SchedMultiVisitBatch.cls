public class SchedMultiVisitBatch implements Database.Batchable<sObject>{
   public final String Query;
   public final WOSchedulePayload thePayload;
   public final set<id> theIds;

   public SchedMultiVisitBatch(WOSchedulePayload payLoad){
             thePayload=payLoad; 
             theIds = new set<id>();
             system.debug('thepayload inside the batch job = ' + thePayload);
             for(id theid : thePayload.resourceIds) theIds.add(theid);
             Query = 'Select id,name from ServiceResource where id in: theIds';
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, 
                       List<sObject> scope){

    list<string> resourceIdList = thePayload.resourceIds;
    WoSchedulePayload iPL = thePayload;
    system.debug('ipl = ' + iPL)  ;                     
    integer numWeeks = iPL.numweeks;
    string territoryid = iPL.territoryid;
    string workorderid = iPL.workorderid;
    string status = iPL.status;
    string taskDescription = iPL.taskDescription;
    date starting = iPL.starting;
    date until = iPL.until;
    list<string> startTimeTextList = iPL.startTimeTextList; 
    list<integer> startTimeHour = new list<integer>{9,9,9,9,9,9,9};
    list<integer> startTimeMinute = new list<integer>{0,0,0,0,0,0,0};                       
    list<integer> durationList = iPL.durationList;
    string mystring = '';
    
    list<integer> selecteddays = new list<integer>(); 
    if(iPL.dow.containsIgnoreCase('Sunday')) selecteddays.add(0);
    if(iPL.dow.containsIgnoreCase('Monday')) selecteddays.add(1);
    if(iPL.dow.containsIgnoreCase('Tuesday')) selecteddays.add(2);
    if(iPL.dow.containsIgnoreCase('Wednesday')) selecteddays.add(3);
    if(iPL.dow.containsIgnoreCase('Thursday')) selecteddays.add(4);
    if(iPL.dow.containsIgnoreCase('Friday')) selecteddays.add(5);
    if(iPL.dow.containsIgnoreCase('Saturday')) selecteddays.add(6);
    //for loop does basic data validation since my lightning component doesn't validate everything                       
    for (integer x=0 ; x< 7;x++)   {
        //only allow durations between 0 and 18 hours
        if(durationList[x] < 0 || durationList[x] > 18) durationList[x] = 8;
        //check if start time is hh:mm am/pm. if not it defaults to 09:00 AM 
        //also if user entered pm, then add 12 to the hours
        if(startTimeTextList[x].length() == 8) {
          string h = startTimeTextList[x].substring(0,2);
          string m = startTimeTextList[x].substring(3,5);
          string a = startTimeTextList[x].substring(6,8);
            if(h.isNumeric() && integer.valueof(h) <=12 && integer.valueof(h) >=0 ) {
              startTimeHour[x] = integer.valueof(h);
              if(m.isNumeric() && integer.valueof(m) <=59 && integer.valueof(m) >=0 ) {
                    startTimeMinute[x] = integer.valueof(m);
                    if(a.toUpperCase() == 'PM') startTimeHour[x]+=12; 
                }
            }          
        }
        system.debug('day: ' + x + ' ' + startTimeTextList[x] + ' ' + startTimeHour[x] + ' ' + startTimeMinute[x] );
    } 
    if (status == null)  status = 'Scheduled';                     
    
                           
    list<serviceappointment> newSAs = new list<serviceappointment>();
    list<assignedresource> newARs = new list<assignedresource>();
    workorder thewo = [select id, subject, city, state, street, postalcode/*,go_number__c,job_number__c */ from workorder where id =: workorderid limit 1];
    if(taskDescription == null ) taskDescription = thewo.subject;
    for(Sobject s : scope) {
        ServiceResource theSR = (ServiceResource)S;
        string theResourceId = theSR.id;
    
        for (integer thedayofweek : selecteddays ) {
            integer duration = 8;  
            if(durationList[thedayofweek] > 0) duration = durationList[thedayofweek];
            serviceappointment thesa = new serviceappointment();            
            thesa.parentrecordid = workorderid;
            thesa.serviceterritoryid = territoryid;
            thesa.durationtype = 'hours';
            thesa.duration = duration;
            thesa.earlieststarttime = datetime.newinstance(starting.adddays(thedayofweek).year(),starting.adddays(thedayofweek).month(),starting.adddays(thedayofweek).day(),startTimeHour[thedayofweek],startTimeMinute[thedayofweek],0);
            thesa.duedate = thesa.earlieststarttime.adddays(1).addminutes(-1);
            thesa.schedstarttime = thesa.earlieststarttime;
            thesa.schedendtime = thesa.schedstarttime.addhours(duration);
            thesa.MR_Parent_Work_Order__c = workorderid;
            thesa.FSL__GanttLabel__c = thewo.subject;
            thesa.city = thewo.city;
            thesa.street = thewo.street;
            thesa.state = thewo.state;
            thesa.postalcode = thewo.postalcode;
            thesa.MR_Service_Resource__c = theResourceId.trim();
            thesa.Status = status;
            thesa.subject = taskDescription;
            newSAs.add (thesa);
              
        }
   }
       if(newSAs.size()>0) {
           insert newSAs;  
           for(serviceappointment thesa : newSAs) {
              assignedresource ar = new assignedresource();
              ar.serviceappointmentid = thesa.id;
              ar.serviceresourceid = thesa.MR_Service_Resource__c;
              newARs.add(ar);
           }   
           if (newARs.size()>0) insert newARs; 
       }                             
  }
   public void finish(Database.BatchableContext BC){

   }

}