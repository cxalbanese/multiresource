@isTest
public class MRDTSchedMultiVisitTestClass{

static testMethod void validateMRDTSchedMultiVisit() {

id usrid = UserInfo.getUserId();
worktype wt = new worktype(name='test',estimatedduration=1,durationtype='hours');
operatinghours oh = new operatinghours(name='test');
insert oh;
serviceterritory st = new serviceterritory(name='test',isactive=true,operatinghoursid=oh.id);
serviceresource sr = new serviceresource(name='test',isactive=true,relatedrecordid=usrid,resourcetype='T');
insert wt;
insert st;
insert sr;
serviceterritorymember stm = new serviceterritorymember (serviceresourceid=sr.id,serviceterritoryid = st.id,effectivestartdate = datetime.now());
insert stm;

workorder wo = new workorder();
wo.worktypeid = wt.id;
wo.serviceterritoryid = st.id;
insert wo;
MRDTSchedMultiVisit.WODTSchedulePayload payload = new MRDTSchedMultiVisit.WODTSchedulePayload();
payload.listSTM = new list<serviceterritorymember>{stm};
payload.territoryId = st.id;
payload.workorderid=wo.id;
payload.starting = date.today();
payload.until = date.today().adddays(7);
payload.startTime = '08:00 AM';
payload.defaultDuration = 8;
payload.status = 'Scheduled';
payload.taskDescription = 'test';
payload.limitSAs = 100;
payload.includeWeekendDay1 = true;
payload.includeWeekendDay2 = true;
list<MRDTSchedMultiVisit.WODTSchedulePayload> inputList = new list<MRDTSchedMultiVisit.WODTSchedulePayload>{payload};

list<MRDTSchedMultiVisit.WODTScheduleOutput> outputList = MRDTSchedMultiVisit.MRDTMV(inputList);


}



}