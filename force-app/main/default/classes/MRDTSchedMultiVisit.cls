//MRDTSchedMultiVisit Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Create draft SAs for the selected STMs and date range specified
//Called by: Flow: MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public class MRDTSchedMultiVisit {

@invocableMethod (label='MR DT Create Multiple Visits')
public static list<WODTScheduleOutput> MRDTMV (list<WODTSchedulePayload> inPayloadList) {

    WODTSchedulePayload iPL = inPayloadList[0];
    list<serviceterritorymember> listSTM = iPL.listSTM;
    boolean includeWeekendDay1 = iPL.includeWeekendDay1;
    boolean includeWeekendDay2 = iPL.includeWeekendDay2;
    string weekendDay1 = 'Sat';
    string weekendDay2 = 'Sun';
    integer limitSAs = iPL.limitSAs;
    system.debug('ipl = ' + iPL)  ;     
    string territoryid = iPL.territoryid;
    string workorderid = iPL.workorderid;
    string status = iPL.status;
    string taskDescription = iPL.taskDescription;
    date starting = iPL.starting;
    date until = iPL.until;
    string startTime = iPL.startTime;
    integer duration = iPL.defaultDuration;  
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
    
                           
    list<serviceappointment> listNewSAs = new list<serviceappointment>();
    list<serviceappointment> listSavedSAs = new list<serviceappointment>();
    list<assignedresource> newARs = new list<assignedresource>();
    try{
    workorder thewo = [select id, subject, city, state, street, postalcode from workorder where id =: workorderid limit 1];
    if(taskDescription == null ) taskDescription = thewo.subject;
    for(serviceterritorymember stm : listSTM) {
        string theResourceId = stm.serviceresourceid;
    
        for (date thedate : listDate ) {
            datetime dowdatetime = datetime.newinstance(thedate.year(),thedate.month(),thedate.day());
            string dow = datetime.newinstance(thedate.year(),thedate.month(),thedate.day()).format('EEE');
            if((dow == weekendDay1 && includeWeekendDay1) || (dow == weekendDay2 && includeWeekendDay2) || (dow != weekendDay1 && dow != weekendDay2)) {
                serviceappointment thesa = new serviceappointment();            
                thesa.parentrecordid = workorderid;
                thesa.serviceterritoryid = territoryid;
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
                thesa.MR_Service_Resource__c = theResourceId.trim();
                thesa.Status = status;
                thesa.subject = taskDescription;
                thesa.MR_Creation_Status__c = 'Draft';
                listNewSAs.add (thesa);
            }  
        }
   }
       if(listNewSAs.size()>0 && listNewSAs.size()<= limitSAs) {
           insert listNewSAs;  
           for(serviceappointment sa: [select appointmentnumber, parentrecordid,serviceterritoryid,durationtype,duration,earlieststarttime,duedate,schedstarttime,schedendtime,mr_parent_work_order__c,fsl__ganttlabel__c,city,street,postalcode,mr_service_resource__c,status,mr_creation_status__c from serviceappointment where id in :listNewSAs])
                listSavedSAs.add(sa);
           WODTScheduleOutput saOutput = new WODTScheduleOutput();
           saOutput.listSA = new list<serviceappointment>(listSavedSAs);
           saOutput.numSAs = listNewSAs.size();
           return new list<WODTScheduleOutput>{saOutput};
           }
       if(listNewSAs.size()>limitSAs) {
           WODTScheduleOutput saOutput = new WODTScheduleOutput();
           saOutput.listSA = new list<serviceappointment>();
           saOutput.numSAs = listNewSAs.size();
           return new list<WODTScheduleOutput>{saOutput};
           }           
       WODTScheduleOutput saOutput = new WODTScheduleOutput();
       saOutput.listSA = new list<serviceappointment>();
       saOutput.numSAs = 0;
       return new list<WODTScheduleOutput>{saOutput};
      }
      catch(exception e) {
       WODTScheduleOutput saOutput = new WODTScheduleOutput();
       saOutput.listSA = new list<serviceappointment>();
       saOutput.numSAs = 0;
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
}

public class WODTScheduleOutput {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public integer numSAs;}
}