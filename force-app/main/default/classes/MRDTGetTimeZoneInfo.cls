//MRDTGetTimeZoneInfo Author: Chris Albanese, Version 1, Created Jan 1, 2022
//Purpose: Determine time zone difference between user's time zone and selected territory's timezone
//Returning a non zero value means that the running users time zone is different from the selected territory
//Called by: Flow: MR_DT_Service_Appointment_Creator
//Disclaimer: Use at your own risk: this code is provided as a concept illustrator to manage multiple service appointments for a work order
//Disclaimer: This code does not use the scheduling features of SFS and will produce scheduling violations on your Gantt

public With Sharing class MRDTGetTimeZoneInfo {

    @invocableMethod(label='MRDT Get Time Zone Info')
    public static list<payLoadOut> MRDTGetTimeZoneInfo(list<string> inTerritoryIdList) { 

        payLoadOut pLoadOut = new payLoadOut();
        ploadOut.hours = 0;
        ploadOut.yourTimeZone = null;
        ploadOut.territoryTimeZone = null;


        try{
            string territoryId = inTerritoryIdList[0];
            TimeZone userTZ = UserInfo.getTimeZone();
            OperatingHours oh = new OperatingHours();
            if(Schema.sObjectType.operatinghours.isQueryable() && Schema.sObjectType.serviceterritory.isQueryable())
                oh = [select id,timezone from operatinghours where id in (select operatinghoursid from serviceterritory where id = : territoryId) limit 1];
            TimeZone territoryTZ = Timezone.getTimeZone(oh.timezone);
            Datetime compareDateTime = 
            Datetime.newInstanceGmt(2021,7,18,12,0,0);
            String strDtuser = compareDateTime.format('yyyy-mm-dd HH:mm:ss',userTZ.getId());
            String strDtterritory = compareDateTime.format('yyyy-mm-dd HH:mm:ss',territoryTZ.getId());
            Datetime userDate = Datetime.valueOfGMT(strDtuser);
            Datetime territoryDate = Datetime.valueOfGMT(strDtterritory);
            Long userDateLong = userDate.getTime();
            Long territoryDateLong = territoryDate.getTime();
            Long milliseconds = territoryDateLong - userDateLong;
            Long hours = ((milliseconds / 1000) / 60) / 60;
            ploadOut.hours = hours;
            ploadOut.yourTimeZone = userTZ.getId();
            ploadOut.territoryTimeZone = territoryTZ.getId();    
            return new list<payLoadOut>{ploadOut};
        }
        catch(exception e){
            return new list<payLoadOut>{ploadOut};
        }
    }


    public class payLoadOut {
        @invocableVariable
        public long hours;
        @invocableVariable
        public string yourTimeZone;
        @invocableVariable
        public string territoryTimeZone;
    }
}