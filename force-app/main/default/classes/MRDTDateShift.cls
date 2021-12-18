//MRDTDATEShift Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: Shift Service Appointments from their current date to a new date specified by the user
//Called by: Flow: MR_DT_Service_Appointment_Review
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public class MRDTDateShift {

@invocableMethod (label='MR DT Date Shift')
public static list<WODTScheduleOutput> DateShift (list<WODTSchedulePayload> inPayloadList) {

    WODTSchedulePayload iPL = inPayloadList[0];
    list<serviceappointment> listSA = iPL.listSA;
    list<serviceappointment> listShiftedSA = new list<serviceappointment>();
    set<date> setDate = new set<date>();
    date dateStarting = iPL.dateStarting;
    date dateEnding = iPL.dateEnding;
    date dateNewStart = iPL.dateNewStart;
    if(dateEnding == null) dateEnding = date.newinstance(2099,12,31);
 
    for(serviceappointment sa :listSA){
        if(sa.schedstarttime.date() >= dateStarting && sa.schedendtime.date() <= dateEnding) {
            listShiftedSA.add(sa);
        }
    }

    integer daysOffset = dateStarting.daysbetween(dateNewStart);
    date saStartDate = listShiftedSA[0].schedstarttime.date();
    date saEndDate = listShiftedSA[listShiftedSA.size()-1].schedstarttime.date().adddays(2);


                                              
    for (serviceappointment sa : listShiftedSA) {
            string dow = datetime.newinstance(sa.schedstarttime.year(),sa.schedstarttime.month(),sa.schedstarttime.day()).format('EEE');
                integer dateDaysOffset = daysOffset;
                sa.earlieststarttime = sa.earlieststarttime.adddays(dateDaysOffset);
                sa.duedate = sa.duedate.adddays(dateDaysOffset);
                sa.schedstarttime = sa.schedstarttime.adddays(dateDaysOffset);
                sa.schedendtime = sa.schedstarttime.addhours(dateDaysOffset);
     }
   
       if(listShiftedSA.size()>0 ) {
           update listShiftedSA;  
           WODTScheduleOutput saOutput = new WODTScheduleOutput();
           saOutput.listSA = new list<serviceappointment>(listShiftedSA);
           saOutput.numSAs = listShiftedSA.size();
           return new list<WODTScheduleOutput>{saOutput};
           }
       
       WODTScheduleOutput saOutput = new WODTScheduleOutput();
       saOutput.listSA = new list<serviceappointment>();
       saOutput.numSAs = 0;
       return new list<WODTScheduleOutput>{saOutput};
                          
  }


public class WODTSchedulePayload {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public date dateStarting;
@invocableVariable public date dateEnding;
@invocableVariable public date dateNewStart;
}

public class WODTScheduleOutput {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public integer numSAs;
}



}