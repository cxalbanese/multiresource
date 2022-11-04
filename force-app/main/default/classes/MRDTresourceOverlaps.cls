//MRDTresourceOverlaps Author: Chris Albanese, Version 1, Created Nov 4, 2022
//Purpose: profile for a technician of overlaps
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
public with sharing class MRDTresourceOverlaps {
    @AuraEnabled
    public string resourceId='';
    @AuraEnabled
    public string stringpercentAvailability='';
    @AuraEnabled
    public string stringnumberConflicts='';    
    @AuraEnabled
    public decimal percentAvailability=100;
    @AuraEnabled
    public decimal numberConflicts=0;
    @AuraEnabled
    public decimal totalBlockedHours=0;  
    @AuraEnabled
    public map<date,saConflictDetails> mapSAConflictDetails=null;
    public class saConflictDetails {
        public string conflictDetails='';
        public decimal blockedHours=0;
    }
}
