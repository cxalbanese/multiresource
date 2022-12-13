//MRDTresourceOverlaps Author: Chris Albanese, Version 1, Created Nov 4, 2022
//Purpose: profile for a technician of overlaps
//Called by: Flow: MR_DT_Service_Appointment_Review and MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt
//this class represents a service resource, their % availability, number of conflicts as well as a map
//of the dates that have an overlap. that map contains 1 record for each date in the date range
//and the overlap info for that date which includes a text field containing a list of SAs and RAs
//and a total of the blocked hours
public with sharing class MRDTresourceOverlaps {
    public MRDTresourceOverlaps(){}
    @AuraEnabled
    public Integer netNumDays=0;
    @AuraEnabled
    public string resourceId='';
    @AuraEnabled
    public string resourceName='';
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
    public string skillsMatched='';
    @AuraEnabled
    public string skillLevelsMatched='';
    @AuraEnabled
    public string skillNamesMatched='';
    @AuraEnabled
    public map<date,saConflictDetails> mapSAConflictDetails=null;
    public class saConflictDetails {
        public string conflictDetails='';
        public decimal blockedHours=0;
    }
}