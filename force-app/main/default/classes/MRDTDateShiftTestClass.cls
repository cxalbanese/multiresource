@isTest
public class MRDTDateShiftTestClass{

static testMethod void validateMRDTDateShift() {

id usrid = UserInfo.getUserId();
worktype wt = new worktype(name='test',estimatedduration=1,durationtype='hours', ShouldAutoCreateSvcAppt=false);
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
insert new serviceappointment(parentrecordid=wo.id,serviceterritoryid=st.id,earlieststarttime=datetime.now(),duedate=datetime.now().adddays(10),mr_service_resource__c = sr.id, schedstarttime=datetime.now(),schedendtime=datetime.now().addhours(1),status='Scheduled');
list<serviceappointment> listSA = new list<serviceappointment>([select appointmentnumber,earlieststarttime,duedate,schedstarttime,schedendtime,mr_service_resource__c from serviceappointment where parentrecordid = :wo.id]);
MRDTDateShift.WODTSchedulePayload payload = new MRDTDateShift.WODTSchedulePayload();
payload.listSA = new list<serviceappointment>(listSA);
payload.dateStarting = date.today();
payload.dateEnding = date.today().adddays(7);
payload.dateNewStart = date.today().adddays(100);
list<MRDTDateShift.WODTSchedulePayload> inputList = new list<MRDTDateShift.WODTSchedulePayload>{payload};

list<MRDTDateShift.WODTScheduleOutput> outputList = MRDTDateShift.DateShift(inputList);


}



}