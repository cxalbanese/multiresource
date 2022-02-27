//WOSchedulePayload Author: Chris Albanese, Version 1, Created Dec 16, 2021
//Purpose: not currently used
//Called by: Flow: MR_DT_Service_Appointment_Review
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public class WOSchedulePayload {
    
public WOSchedulePayload() {}
public list<string> resourceIds;
public string territoryId;
public integer numWeeks;
public string workorderid;
public date starting;
public date until;
public string dow;
public list<string> startTimeTextList;
public list<integer> durationList;
public string status;
public string taskDescription;
}