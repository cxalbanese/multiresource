public class MRDTDateShift {

@invocableMethod (label='MR DT Date Shift')
public static list<WODTScheduleOutput> DateShift (list<WODTSchedulePayload> inPayloadList) {

    WODTSchedulePayload iPL = inPayloadList[0];
    list<serviceappointment> listSA = iPL.listSA;
    list<serviceappointment> listShiftedSA = new list<serviceappointment>();
    boolean includeWeekendDay1 = iPL.includeWeekendDay1;
    boolean includeWeekendDay2 = iPL.includeWeekendDay2;
    string weekendDay1 = 'Sat';
    string weekendDay2 = 'Sun';
    date dateStarting = iPL.dateStarting;
    date dateEnding = iPL.dateEnding;
    date dateNewStart = iPL.dateNewStart;
    if(dateEnding == null) dateEnding = date.newinstance(2099,12,31);
 
    list<ServiceAppointmentWrapper> listSAWrap = new list<ServiceAppointmentWrapper>();    
    for(serviceappointment sa :listSA){
        if(sa.schedstarttime.date() >= dateStarting && sa.schedendtime.date() <= dateEnding) {
            listShiftedSA.add(sa);
            listSAWrap.add(new ServiceAppointmentWrapper(sa));
        }
    }
    listSAWrap.sort();
    for(integer x=0;x<listSAWrap.size();x++) listShiftedSA[x]=listSAWrap[x].SA;

    integer daysOffset = dateStarting.daysbetween(dateNewStart);
                                              
    for (serviceappointment sa : listShiftedSA) {
            string dow = datetime.newinstance(sa.schedstarttime.year(),sa.schedstarttime.month(),sa.schedstarttime.day()).format('EEE');
     //       if((dow == weekendDay1 && includeWeekendDay1) || (dow == weekendDay2 && includeWeekendDay2) || (dow != weekendDay1 && dow != weekendDay2)) {            
                sa.earlieststarttime = sa.earlieststarttime.adddays(daysOffset);
                sa.duedate = sa.duedate.adddays(daysOffset);
                sa.schedstarttime = sa.schedstarttime.adddays(daysOffset);
                sa.schedendtime = sa.schedstarttime.addhours(daysOffset);
     //           listShiftedSA.add (sa);
     //       }  
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
@invocableVariable public boolean includeWeekendDay1;
@invocableVariable public boolean includeWeekendDay2;
}

public class WODTScheduleOutput {
  
@invocableVariable public list<serviceappointment> listSA;
@invocableVariable public integer numSAs;
}

public class ServiceAppointmentWrapper implements Comparable {

    public ServiceAppointment SA;
    
    // Constructor
    public ServiceAppointmentWrapper(ServiceAppointment inSA) {
        SA = inSA;
    }
    
    // Compare sas based on the schedstarttime.
    public Integer compareTo(Object compareTo) {
        // Cast argument to ServiceAppointmentWrapper
        ServiceAppointmentWrapper compareToSA = (ServiceAppointmentWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (SA.SchedStartTime > compareToSA.SA.SchedStartTime) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (SA.SchedStartTime < compareToSA.SA.SchedStartTime) {
            // Set return value to a negative value.
            returnValue = -1;
        } else if ((SA.SchedStartTime == null) && (compareToSA.SA.SchedStartTime != null)){
            // nulls-first implementation
            returnValue = -1;
        } else if ((SA.SchedStartTime != null) && (compareToSA.SA.SchedStartTime == null)){
            // nulls-first implementation
            returnValue = 1;
        }        
        return returnValue;       
    }
}

}