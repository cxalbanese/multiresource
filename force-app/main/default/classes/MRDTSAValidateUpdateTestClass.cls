@isTest
public class MRDTSAValidateUpdateTestClass{

static testMethod void validateMRDTValidateUpdate() {

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
MRDTSAValidateUpdate.WODTSchedulePayload payload = new MRDTSAValidateUpdate.WODTSchedulePayload();
payload.woID = wo.id;
list<MRDTSAValidateUpdate.WODTSchedulePayload> inputList = new list<MRDTSAValidateUpdate.WODTSchedulePayload>{payload};

list<MRDTSAValidateUpdate.WODTScheduleOutput> outputList = MRDTSAValidateUpdate.SAValidateUpdate(inputList);

}



}